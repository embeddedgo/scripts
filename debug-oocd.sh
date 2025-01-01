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

HALT='monitor halt'
if [ "$RESET" ]; then
	RESET="monitor reset_config $RESET"
	HALT='monitor reset halt'
fi

elf="$(basename $(pwd)).elf"

if [ -z "$GDB" ]; then
	aa=$(echo $(od -An -t x1 -j 18 -N 1 $elf))
	case "$aa" in
	28)
		GDB=arm-none-eabi-gdb
		;;
	f3)
		GDB=riscv64-unknown-elf-gdb
		;;
	*)
		GDB=gdb-multiarch
	esac
	if [ -z "$(command -v $GDB)" ]; then
		GDB=gdb-multiarch
	fi
fi

if [ -z "$(command -v $GDB)" ]; then
	echo "cannot find $GDB"
	exit 1
fi

if [ -z "$OOCD" ]; then
	OOCD=openocd
fi

if [ -z "$(command -v $OOCD)" ]; then
	echo "cannot find $OOCD"
	exit 1
fi

if [ "$SPEED" ]; then
	SPEED="adapter speed $SPEED"
else
	SPEED='echo -n ""'
fi

oocd_cmd="$OOCD -d0 -f interface/$INTERFACE.cfg -f target/$TARGET.cfg -c '$SPEED' -c 'gdb_port pipe; log_output oocd.log' $@"

$GDB --tui \
	-ex "target extended-remote | $oocd_cmd" \
	-ex 'set mem inaccessible-by-default off' \
	-ex 'set history save on' \
	-ex 'set history filename ~/.gdb-history-embeddedgo' \
	-ex 'set history size 1000' \
	-ex "$RESET" \
	-ex "$HALT" \
	$elf

