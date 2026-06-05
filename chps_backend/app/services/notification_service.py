from sqlalchemy.orm import Session

def notify_resource_created(
    db: Session,
    resource_type: str,
    resource_id: int,
    created_by: int | None,
    summary: str,
):
    """Convenience wrapper to avoid circular imports."""
    from app.controllers.notifications_controller import create_notification
    create_notification(
        db=db,
        message=f"New {resource_type}: {summary}",
        resource_type=resource_type,
        resource_id=resource_id,
        created_by=created_by,
    )
