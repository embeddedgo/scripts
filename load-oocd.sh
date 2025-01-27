#!/bin/sh

set -e

if [ "$INTERFACE" ]; then
	: # set explicitly
elif lsusb -d '0d28:0204'; then
	INTERFACE=cmsis-dap
elif lsusb -d '0483:374b'; then
	INTERFACE=stlink # V2-1
elif lsusb -d '0483:3748'; then
	INTERFACE=stlink # V2
else
	echo "Can not detect debug interface. Please set INTERFACE in $0"
	exit 1
fi

itmsplit=cat
exit=exit

if [ -n "$TRACECLKIN" ]; then
	tpiu="tpiu config external uart off $TRACECLKIN 2000000"
	if [ "$INTERFACE" = 'stlink' -o "$INTERFACE" = 'stlink-dap' ]; then
		# Reduce speed to 200 kb/s because of problems with some ST-LINK
		tpiu="tpiu config internal /dev/stdout uart off $TRACECLKIN 200000"
		itmsplit='itmsplit p1:/dev/stdout /dev/stderr'
		exit=''
	fi
	itm='itm ports on'
fi

name=$(basename $(pwd))
img=$name.hex # prefer hex
if [ ! -f $img ]; then
	img=$name.elf
fi
if [ ! -f $img ]; then
	echo "no application file to load"
	exit 1
fi
settings='sleep 0'
if [ -f $name-settings.hex ]; then
	settings="program $name-settings.hex"
fi

if [ -z "$OOCD" ]; then
	OOCD=openocd
fi

if [ -z "$(command -v $OOCD)" ]; then
	echo "cannot find $OOCD"
	exit 1
fi

if [ "$RESET" ]; then
	RESET="reset_config $RESET"
else
	RESET='echo -n ""'
fi

if [ "$SPEED" ]; then
	SPEED="adapter speed $SPEED"
else
	SPEED='echo -n ""'
fi

# This load script uses 'reset init' instead of 'reset halt' like the debug
# script because it must setup the targed for flashing.

$OOCD -d0 -f interface/$INTERFACE.cfg -f target/$TARGET.cfg \
	-c 'tcl_port disabled' \
	-c 'telnet_port disabled' \
	-c "$SPEED" \
	-c "$RESET" \
	-c 'init' \
	-c 'reset init' \
	-c "program $img" \
	-c "$settings" \
	-c "$tpiu" \
	-c "$itm" \
	-c 'reset run' \
	-c "$exit" \
	|$itmsplit
