#!/bin/sh

set -e

gdb_cmd=gdb
if command -v arm-none-eabi-gdb; then
	gdb_cmd=arm-none-eabi-gdb
elif command -v gdb-multiarch; then
	gdb_cmd=gdb-multiarch
fi

oocd_cmd="openocd -d0 -f interface/$INTERFACE.cfg -f target/$TARGET.cfg -c 'gdb_port pipe' -c 'log_output /dev/null'"

brkpnt=6
wchpnt=4

$gdb_cmd --tui \
	-ex "target extended-remote | $oocd_cmd" \
	-ex 'set mem inaccessible-by-default off' \
	-ex "set remote hardware-breakpoint-limit $brkpnt" \
	-ex "set remote hardware-watchpoint-limit $wchpnt" \
	-ex 'set history save on' \
	-ex 'set history filename ~/.gdb-history-embeddedgo' \
	-ex 'set history size 1000' \
	"$(basename $(pwd)).elf"
