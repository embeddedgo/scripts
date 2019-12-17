#!/bin/sh

set -e

itmsplit=cat
exit=exit

if [ -n "$TRACECLKIN" ]; then
	tpiu="tpiu config external uart off $TRACECLKIN 2000000"
	if [ "$INTERFACE" = 'stlink' ]; then
		# Reduce speed to 200 kb/s because of problems with some ST-LINK
		tpiu="tpiu config internal /dev/stdout uart off $TRACECLKIN 200000"
		itmsplit='itmsplit p1:/dev/stdout /dev/stderr'
		exit=''
	fi
	itm='itm ports on'
fi

openocd -d0 -f interface/$INTERFACE.cfg -f target/$TARGET.cfg  \
	-c 'init' \
	-c 'reset init' \
	-c "program $(basename $(pwd)).elf" \
	-c "$tpiu" \
	-c "$itm" \
	-c 'reset run' \
	-c "$exit" \
	|$itmsplit
