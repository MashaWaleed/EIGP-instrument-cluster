# CAN bus protocol

Dashboard telemetry is received over SocketCAN on the Raspberry Pi (`can0`, MCP2515).

| Property | Value |
|----------|-------|
| Bit rate | 125 kbit/s |
| Frame type | Standard 11-bit ID |
| Endianness | Big-endian for multi-byte values |

## Bring up the interface

On the Pi before starting the cluster:

```bash
ip link set can0 down
ip link set can0 type can bitrate 125000 restart-ms 100
ip link set can0 up
```

Check `ip -details link show can0` — should be `state UP` / `ERROR-ACTIVE`, not `BUS-OFF`.

Override the interface name with `EIGP_CAN_INTERFACE` if needed (default: `can0`).

## Message definitions

### 0x100 — Torque request (confirmed)

Transmitted by the vehicle ECU / knob controller.

| Byte | Type | Description |
|------|------|-------------|
| 0 | `uint8` | Torque request 0–100 % |

DLC: 1

Example (50 %): `cansend can0 100#32`

### 0x101 — Motor RPM (assigned)

| Byte | Type | Description |
|------|------|-------------|
| 0–1 | `uint16` BE | RPM, 0–8000 |

DLC: 2

Example (3200 RPM): `cansend can0 101#0C80`

### 0x102 — Battery current (assigned)

| Byte | Type | Description |
|------|------|-------------|
| 0–1 | `uint16` BE | Current in 0.1 A steps (1800 = 180.0 A) |

DLC: 2

Example (180.0 A): `cansend can0 102#0708`

### 0x103 — Battery temperature (assigned)

| Byte | Type | Description |
|------|------|-------------|
| 0 | `int8` | Temperature in °C (-40 to +127) |

DLC: 1

Example (41 °C): `cansend can0 103#29`

## Not on CAN yet

- **Vehicle speed** — no CAN ID assigned; the gauge stays at 0 in vehicle firmware until a message is defined.

## Firmware modes

| CMake option | Data source | Keyboard (spacebar) |
|--------------|-------------|---------------------|
| `EIGP_DEMO_FIRMWARE=OFF` (default) | CAN only | Ignored |
| `EIGP_DEMO_FIRMWARE=ON` | Simulated from torque | Sets torque 0–100 % |

Vehicle build:

```bash
cmake -S . -B build/raspberrypi-armv8-Debug -DCMAKE_BUILD_TYPE=Debug
```

Demo build (desktop bench testing):

```bash
cmake -S . -B build/desktop-demo -DCMAKE_BUILD_TYPE=Debug -DEIGP_DEMO_FIRMWARE=ON
```

## Monitor traffic

```bash
candump can0
```

Send test frames:

```bash
cansend can0 100#64    # 100 % torque
cansend can0 101#0BB8  # 3000 RPM
cansend can0 102#0708  # 180.0 A
cansend can0 103#29    # 41 °C
```
