import asyncio
import json
from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.notification_model import NotificationModel
from app.models.user_model import UserModel
from app.schemas.notification_schema import NotificationResponse
from app.security import get_current_user, require_admin

router = APIRouter(prefix="/notifications", tags=["Notifications"])

# SSE subscribers: set of asyncio.Queue
_sse_queues: set[asyncio.Queue] = set()

async def _notify_subscribers(notification: dict):
    """Push a notification to all connected admin SSE clients."""
    message = f"data: {json.dumps(notification, default=str)}\n\n"
    dead: list[asyncio.Queue] = []
    for q in _sse_queues:
        try:
            q.put_nowait(message)
        except asyncio.QueueFull:
            dead.append(q)
    for q in dead:
        _sse_queues.discard(q)

def create_notification(
    db: Session,
    message: str,
    resource_type: str,
    resource_id: int | None = None,
    created_by: int | None = None,
):
    """Create a notification record and push to SSE subscribers."""
    notif = NotificationModel(
        message=message,
        resource_type=resource_type,
        resource_id=resource_id,
        created_by=created_by,
    )
    db.add(notif)
    db.commit()
    db.refresh(notif)
    # Fire-and-forget: push to SSE in background
    import threading
    threading.Thread(
        target=lambda: asyncio.run(_notify_subscribers({
            "id": notif.id,
            "message": notif.message,
            "resource_type": notif.resource_type,
            "resource_id": notif.resource_id,
            "created_by": notif.created_by,
            "created_at": notif.created_at.isoformat(),
            "is_read": notif.is_read,
        })),
        daemon=True,
    ).start()
    return notif

@router.get("", response_model=List[NotificationResponse])
def list_notifications(
    unread_only: bool = Query(False),
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(require_admin),
):
    query = db.query(NotificationModel).order_by(NotificationModel.created_at.desc()).limit(50)
    if unread_only:
        query = query.filter(NotificationModel.is_read == False)
    return query.all()

@router.put("/{id}/read", response_model=NotificationResponse)
def mark_read(
    id: int,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(require_admin),
):
    notif = db.query(NotificationModel).filter(NotificationModel.id == id).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    notif.is_read = True
    db.commit()
    db.refresh(notif)
    return notif

@router.put("/read-all")
def mark_all_read(
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(require_admin),
):
    db.query(NotificationModel).filter(NotificationModel.is_read == False).update({"is_read": True})
    db.commit()
    return {"ok": True}

@router.get("/stream")
def stream_notifications(current_user: UserModel = Depends(require_admin)):
    """Server-Sent Events endpoint for real-time notifications."""
    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue(maxsize=100)
        _sse_queues.add(queue)
        try:
            while True:
                message = await queue.get()
                yield message
        except asyncio.CancelledError:
            pass
        finally:
            _sse_queues.discard(queue)

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
