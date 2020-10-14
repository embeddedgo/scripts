#!/bin/sh

set -e

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
	RESET="echo -n ''"
fi

$OOCD -d0 -f interface/$INTERFACE.cfg -f target/$TARGET.cfg  \
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
