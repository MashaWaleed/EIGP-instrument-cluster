# EIGP Instrument Cluster

Qt Quick instrument cluster for Raspberry Pi 5 running Boot2Qt.

## Features

- Full-screen QML dashboard with splash screen
- Vehicle firmware: live telemetry from CAN bus (MCP2515 / `can0`)
- Demo firmware: simulated gauges driven by spacebar torque input
- RPM, current, and temperature from dedicated CAN frames; speed not on bus yet

## Project layout

```text
.
├── src/
│   ├── main.cpp
│   ├── dashboarddatacontroller.{h,cpp}   # QML data model
│   ├── dashboardcansource.{h,cpp}        # SocketCAN reader (vehicle build)
│   └── canprotocol.h                     # CAN ID definitions
├── qml/
├── assets/
├── resources/qml.qrc
├── docs/can-protocol.md                  # CAN IDs and payload format
└── docs/raspberry-pi5/README.md
```

## Requirements

- Qt 6.10+ with `Core`, `Quick`, and `Qml`
- CMake 3.16+
- Boot2Qt on Raspberry Pi 5 — see [docs/raspberry-pi5/README.md](docs/raspberry-pi5/README.md)
- MCP2515 CAN HAT on `can0` at 125 kbit/s for vehicle firmware

## Build

### Vehicle firmware (CAN, default)

```bash
source /home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/toolchain/environment-setup-cortexa53-poky-linux

cmake -S . -B build/raspberrypi-armv8-Debug -DCMAKE_BUILD_TYPE=Debug
cmake --build build/raspberrypi-armv8-Debug --target eigp-instrument-cluster install
```

### Demo firmware (simulated data + keyboard)

```bash
cmake -S . -B build/desktop-demo -DCMAKE_BUILD_TYPE=Debug -DEIGP_DEMO_FIRMWARE=ON
cmake --build build/desktop-demo --target eigp-instrument-cluster
```

Hold **spacebar** in demo mode to drive torque; RPM, speed, current, and temperature follow from that value.

## CAN input

See [docs/can-protocol.md](docs/can-protocol.md) for message IDs and payload layout.

| Variable | Description |
|----------|-------------|
| `EIGP_CAN_INTERFACE` | CAN interface name (default `can0`) |

Bring up the bus on the Pi:

```bash
ip link set can0 type can bitrate 125000
ip link set can0 up
```

## Development notes

- QML reads `dashboardController` (torque, rpm, speed, current, temperature).
- `dashboardController.dataSource` is `"can"` or `"demo"` depending on the build.
- Assets must be listed in `resources/qml.qrc`.
