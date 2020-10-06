#!/bin/sh

set -e

if [ -z "$OBJCOPY" ]; then
	OBJCOPY=objcopy
fi

name=$(basename $(pwd))
$OBJCOPY -O binary $name.elf $name.bin
st-flash --reset write $name.bin 0x8000000
rm $name.bin