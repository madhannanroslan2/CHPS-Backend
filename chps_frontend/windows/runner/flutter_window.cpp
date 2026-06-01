#include "flutter_window.h"
#include "utils.h"
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

FlutterWindow::FlutterWindow(const flutter::DartProject& project) : project_(project) {}
FlutterWindow::~FlutterWindow() = default;

bool FlutterWindow::CreateAndShow(const std::wstring& title, HINSTANCE, int width, int height) { return true; }
