# EIGP Instrument Cluster

Qt Quick instrument cluster for Raspberry Pi 5 running Boot2Qt.

## Features

- Full-screen QML dashboard with splash screen
- UART-backed torque input via `DashboardSerialController`
- Derived RPM, speed, current, and temperature values for bench testing
- Spacebar keyboard fallback for torque input during development

## Project layout

```text
.
├── src/                              # C++ application code
│   ├── main.cpp
│   └── dashboardserialcontroller.{h,cpp}
├── qml/                              # QML UI
│   ├── main.qml                      # Application root
│   ├── DashboardContent.qml          # Main instrument cluster
│   ├── SplashScreen.qml
│   ├── CircularGaugeMeter.qml
│   ├── components/                   # Reusable QML components
│   └── pages/                        # Secondary dashboard pages
├── assets/                           # Bundled media (listed in resources/qml.qrc)
│   ├── fonts/
│   ├── icons/
│   ├── images/
│   └── panels/                       # Gauge and panel artwork
├── resources/
│   └── qml.qrc                       # Qt resource manifest
├── Dashboard.qmlproject              # Qt Design Studio project
├── CMakeLists.txt
└── docs/raspberry-pi5/README.md      # Boot2Qt image and deployment guide
```

## Requirements

- Qt 6.10+ with `Core`, `Quick`, `Qml`, and `SerialPort`
- CMake 3.16+
- Boot2Qt toolchain for Raspberry Pi 5 — see [docs/raspberry-pi5/README.md](docs/raspberry-pi5/README.md)

## Build

### Desktop (local Qt)

```bash
cmake -S . -B build/desktop-Debug -DCMAKE_BUILD_TYPE=Debug
cmake --build build/desktop-Debug --target eigp-instrument-cluster
```

### Raspberry Pi 5 (Boot2Qt cross-build)

```bash
source /home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/toolchain/environment-setup-cortexa53-poky-linux

cmake -S . -B build/raspberrypi-armv8-Debug -DCMAKE_BUILD_TYPE=Debug
cmake --build build/raspberrypi-armv8-Debug --target eigp-instrument-cluster install
```

Open the project in Qt Creator with the **Custom Qt 6.10.3 raspberrypi-armv8** kit for integrated build and deploy.

## Serial input

The dashboard reads torque request values from UART and accepts a keyboard override for testing.

| Variable | Description |
|----------|-------------|
| `DASHBOARD_SERIAL_PORT` | Serial device path override |
| `DASHBOARD_SERIAL_BAUD` | Baud rate override |

Accepted UART payload examples: `42` or `torque=42`

Hold the spacebar in the running app to drive the torque path without serial hardware.

## Development notes

- All QML and asset files consumed at runtime must be listed in `resources/qml.qrc`.
- Qt Design Studio uses `Dashboard.qmlproject`; CMake builds from `resources/qml.qrc`.
- Deployment target on device: `/opt/Dashboard` (configured in `Dashboard.qmlproject`).
