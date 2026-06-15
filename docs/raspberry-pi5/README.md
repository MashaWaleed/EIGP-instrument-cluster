# Raspberry Pi 5 Boot2Qt Image

This document describes the Boot2Qt Linux image and cross-compilation toolchain used to build and deploy the EIGP instrument cluster on Raspberry Pi 5.

## Image location (development host)

The Boot2Qt BSP for Raspberry Pi (64-bit) is installed at:

```text
/home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/
```

| Path | Purpose |
|------|---------|
| `images/b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.wic.xz` | Flashable SD card image |
| `images/b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.info` | Image build metadata |
| `toolchain/environment-setup-cortexa53-poky-linux` | Cross-compilation environment |
| `toolchain/configure-qtcreator.sh` | Registers the Qt Creator kit |
| `toolchain/sysroots/` | Target and SDK sysroots |

## Image details

| Property | Value |
|----------|-------|
| Qt version | 6.10.3 |
| Boot2Qt distro | 5.2.4 (walnascar) |
| Target machine | `raspberrypi-armv8` (Cortex-A53, 64-bit) |
| Deploy profile | Raspberry Pi Development Boards (64bit) |

Official setup guide: [Boot to Qt installation](https://doc.qt.io/Boot2Qt/b2qt-qbsp-installation-guide.html)

## Flash the SD card

1. Decompress the image:

   ```bash
   xz -dk /home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/images/b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.wic.xz
   ```

2. Write the `.wic` file to an SD card (replace `/dev/sdX` with your device):

   ```bash
   sudo dd if=b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.wic of=/dev/sdX bs=4M status=progress conv=fsync
   ```

3. Boot the Raspberry Pi 5 from the SD card and connect it to the same network as the development machine.

## Configure Qt Creator

Register the cross-compilation kit once:

```bash
/home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/toolchain/configure-qtcreator.sh
```

This creates a kit named **Custom Qt 6.10.3 raspberrypi-armv8** with the correct compiler, sysroot, CMake toolchain file, and Boot2Qt device type.

In Qt Creator:

1. Open this repository as a CMake project.
2. Select the Boot2Qt kit for the build configuration.
3. Add a Boot2Qt device under **Preferences → Devices** if one is not already configured.
4. Build and deploy with the **Build → Deploy** or **Run** workflow.

## Build from the command line

Source the toolchain environment, then configure and build:

```bash
source /home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/toolchain/environment-setup-cortexa53-poky-linux

cmake -S /home/masha/Projects/EIGP-instrument-cluster \
      -B /home/masha/Projects/EIGP-instrument-cluster/build/raspberrypi-armv8-Debug \
      -DCMAKE_BUILD_TYPE=Debug

cmake --build /home/masha/Projects/EIGP-instrument-cluster/build/raspberrypi-armv8-Debug \
      --target eigp-instrument-cluster install
```

The installed binary lands under the CMake install prefix configured for your kit (default deployment target in Qt Design Studio: `/opt/Dashboard`).

## Display sizing (squished UI)

The dashboard UI is designed for **1024×600**. If the framebuffer reports a different size (for example `1024,768` from `/sys/class/graphics/fb0/virtual_size`), EGLFS may stretch or squash the scene.

**Check on the Pi:**

```bash
cat /sys/class/graphics/fb0/virtual_size
```

If this is not `1024,600` for your panel, fix the display mode before tuning the app.

**App-side fix (included in this repo):** `qml/main.qml` runs full-screen using `Screen.width` / `Screen.height` on Linux instead of a hard-coded 1024×600 window.

**Force the correct mode (recommended for a 1024×600 panel):**

1. Copy the KMS config to the Pi:

   ```bash
   sudo mkdir -p /etc/eigp
   sudo cp docs/raspberry-pi5/eglfs-kms.json /etc/eigp/eglfs-kms.json
   ```

2. Add to `b2qt.service` (see `b2qt.service.example`):

   ```ini
   Environment=QT_QPA_EGLFS_KMS_CONFIG=/etc/eigp/eglfs-kms.json
   Environment=QT_QPA_EGLFS_ALWAYS_SET_MODE=1
   ```

3. Reload and restart:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart b2qt.service
   ```

Physical panel size (optional, affects DPI) can be set in `b2qt.service`:

```ini
Environment=QT_QPA_EGLFS_PHYSICAL_WIDTH=154
Environment=QT_QPA_EGLFS_PHYSICAL_HEIGHT=90
```

If the framebuffer is taller than the physical panel (for example 1024×768 signal to a 1024×600 display), set the real panel height so the app can compensate:

```ini
Environment=EIGP_PANEL_HEIGHT=600
```

Defaults in `main.cpp` are 154×90 mm. Override via environment instead of rebuilding when possible.

Your Pi uses **HDMI-A-2** on **card0** (not HDMI-A-1). The repo `eglfs-kms.json` targets that connector.

**Update the boot service binary name:** your service still launches `/usr/bin/untitled`. After deploying this project, change it to `/usr/bin/eigp-instrument-cluster` (see `b2qt.service.example`).

## CAN interface at boot

Do **not** put `ip link` commands in `b2qt.service` directly. Use a dedicated systemd unit that runs **before** the app.

1. Copy the unit file to the Pi:

   ```bash
   sudo cp docs/raspberry-pi5/can0.service /etc/systemd/system/
   ```

2. Enable it:

   ```bash
   sudo systemctl enable can0.service
   sudo systemctl start can0.service
   ```

3. Verify:

   ```bash
   ip -details link show can0
   ```

4. Make `b2qt.service` start after CAN (see `b2qt.service.example`):

   ```ini
   After=can0.service
   Wants=can0.service
   ```

   Then `sudo systemctl daemon-reload`.

## Runtime notes

- The application targets EGLFS full-screen rendering on Boot2Qt.
- Vehicle firmware reads dashboard telemetry from CAN (`can0`, MCP2515). See [../can-protocol.md](../can-protocol.md). Override the interface with `EIGP_CAN_INTERFACE` if needed.
- USB OTG device mode is supported on Raspberry Pi 4 only; use network deployment for Pi 5.

## Updating the image

When upgrading Qt or Boot2Qt, install the new BSP through the Qt Maintenance Tool, then update the paths in this document and re-run `configure-qtcreator.sh`.
