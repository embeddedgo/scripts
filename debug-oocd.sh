#!/bin/sh

set -e

elf="$(basename $(pwd)).elf"

if [ -z "$GDB" ]; then
	case $(od -An -t x1 -j 18 -N 1 $elf) in
	28)
		GDB=arm-none-eabi-gdb
		;;
	f3)
		GDB=riscv64-unknown-elf-gdb
		;;
	esac
	if [ -z "$GDB" ]; then
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


oocd_cmd="$OOCD -d0 -f interface/$INTERFACE.cfg -f target/$TARGET.cfg -c 'gdb_port pipe; log_output /dev/null' $@"

$GDB --tui \
	-ex "target extended-remote | $oocd_cmd" \
	-ex 'set mem inaccessible-by-default off' \
	-ex 'set history save on' \
	-ex 'set history filename ~/.gdb-history-embeddedgo' \
	-ex 'set history size 1000' \
	-ex 'monitor halt' \
	$elf
