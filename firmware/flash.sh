#!/usr/bin/env bash
./esptool --port /dev/cu.SLAB_USBtoUART --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 bootloader.bin  0x10000 NodeMCU.bin  0x8000 partitions_singleapp.bin
