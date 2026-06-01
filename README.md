# EIGP Instrument Cluster

Qt Quick / QML instrument cluster application for Raspberry Pi 5 running Boot2Qt.

## Overview

This project renders a custom EV-style dashboard UI and feeds it with live or simulated vehicle data.

- QML-based instrument cluster UI with splash screen and dashboard composition
- UART-backed torque request input through `DashboardSerialController`
- Derived dummy RPM, speed, current, and temperature values for testing
- Keyboard fallback using the spacebar for torque request testing
- Hidden mouse cursor for full-screen HMI deployment

## Project Layout

- `main.cpp`: Qt application bootstrap and `serialController` context setup
- `main.qml`: composition root that wires splash screen and dashboard content
- `DashboardContent.qml`: main instrument cluster UI
- `SplashScreen.qml`: startup splash animation
- `dashboardserialcontroller.cpp` / `dashboardserialcontroller.h`: UART input and generated dashboard data
- `qml.qrc`: Qt resource manifest for QML, images, icons, and fonts
- `Component/`: reusable QML UI components

## Requirements

- Qt 6 with `Core`, `Quick`, `Qml`, and `SerialPort`
- CMake 3.16+
- Raspberry Pi 5 / Boot2Qt target for deployment

## Build

```bash
cmake -S . -B build
cmake --build build --target untitled
```

For this workspace, the validated Boot2Qt build directory is:

```bash
cmake --build /home/masha/untitled/build/6.10.3-raspberrypi-armv8-Debug --target untitled
```

## Serial Input

The dashboard reads torque request input from UART and also supports a keyboard override.

- `DASHBOARD_SERIAL_PORT`: override the serial device path
- `DASHBOARD_SERIAL_BAUD`: override the baud rate

Accepted UART payload examples:

- `42`
- `torque=42`

Holding the spacebar in the app also drives the torque request path for testing.

## Notes

- QML assets used by the app must be listed in `qml.qrc`.
- The deployed binary target is currently named `untitled`.
- The repository name is `EIGP-instrument-cluster`, but the application target has not been renamed yet.