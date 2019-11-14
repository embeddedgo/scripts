#!/bin/sh

itmsplit=cat

tpiu="tpiu config external uart off $TRACECLKIN 2000000"
if [ "$INTERFACE" = 'stlink' ]; then
	# Reduce speed to 200 kb/s because of problems with some ST-LINK
	tpiu="tpiu config internal /dev/stdout uart off $TRACECLKIN 200000"
	itmsplit='itmsplit p1:/dev/stdout /dev/stderr'
fi

openocd -f interface/$INTERFACE.cfg -f target/$TARGET.cfg \
	-c 'init' \
	-c "$tpiu" \
	-c 'itm ports on' \
	|$itmsplit