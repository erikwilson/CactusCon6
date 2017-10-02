#!/usr/bin/env bash

if [ -n "$1" ]
then
  TTYUSB=$1
else
  TTYUSB='/dev/cu.SLAB_USBtoUART'
fi

BAUD=921600
LUATOOL='../setup/luatool.py'
LUATOOLCMD="python3 ${LUATOOL} --baud ${BAUD} --port ${TTYUSB} --delay 0.01"

set -e

(
  cd ../src
  for file in $(ls *.lua); do
    echo
    echo --- $file
    sleep 0.5
    LUATOOLARGS='-c'
    if [ "$file" = "init.lua" ]
    then
      unset LUATOOLARGS
    fi
  	$LUATOOLCMD --src $file -v $LUATOOLARGS >/dev/null
  done
)
echo "upload successful"
