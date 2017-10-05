
# Hardware

Thanks to Tim Hatch for the PCB design, see https://github.com/thatch/cactuscon-badge-2017.

Double check that the VCC and GND of your SSD1306 OLED display match the VCC and GND of the PCB. Unfortunately CactusCon received a shipment of OLEDs where the ordering of GND and VCC are reversed, requiring that those pins be bent or cut and then jumped to their appropriate position on the breakout or header beneath.

# Setup

For links to serial drivers, esptool, and ESPlorer please visit:
https://github.com/nodemcu/nodemcu-devkit/wiki/Getting-Started-on-OSX

These examples use /dev/cu.SLAB_USBtoUART as the serial port to NodeMCU, please change to the appropriate port on your system. Pre-built images in ./firmware are setup to use a baud rate of 921600.

# Flashing the pre-built image

```
esptool --port /dev/cu.SLAB_USBtoUART --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size detect 0x0 ./firmware/cactuscon6.bin
```

# Building the NodeMCU dev-esp32 firmware

Building NodeMCU's dev-esp32 branch is only necessary if you want to enable extra modules which are not available with the pre-built binaries under ./firmware.
```
cd docker-ubuntu-dev-tools
docker build -t docker-ubuntu-dev-tools .

git clone --branch dev-esp32 --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git nodemcu-firmware-esp32
cd nodemcu-firmware-esp32
modify ./components/lua/lmathlib.c and uncomment desired math functions

docker run --cpus 2 --rm -ti -v (pwd):/opt/nodemcu-firmware docker-ubuntu-dev-tools
cd /opt/nodemcu-firmware
make menuconfig
make -j4
exit
```

Also see http://nodemcu.readthedocs.io/en/dev-esp32/en/build/

## Flashing newly built image

```
esptool --port /dev/cu.SLAB_USBtoUART --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size detect 0x1000 ./nodemcu-firmware-esp32/build/bootloader/bootloader.bin  0x10000 ./nodemcu-firmware-esp32/build/NodeMCU.bin  0x8000 ./nodemcu-firmware-esp32/build/partitions_singleapp.bin
```

## Upload your Lua code

ESPlorer is the easiest way to upload your Lua code. Fixes and pull requests for './setup-broken' welcome.

## Saving a pre-built image from uploaded code

```
esptool --port /dev/cu.SLAB_USBtoUART --baud 921600 read_flash 0x0000 4194304 cactuscon6.bin
```
