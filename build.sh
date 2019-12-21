#!/bin/sh

set -e

[ "$IRQNAMES" ] && {
	echo '// DO NOT EDIT THIS FILE. GENERATED BY build.sh.'
	echo
	echo 'package main'
	echo
	echo 'import _ "unsafe"'
	echo
	while read name a1 a2 a3 rest; do
		if [ "$a1" = '=' ]; then
			echo "//go:linkname ${name}_Handler IRQ${a2}_Handler"
		elif [ "$a2" = '=' ]; then
			echo "//go:linkname ${name}_Handler IRQ${a3}_Handler"
		fi
	done <"$IRQNAMES/$GOTARGET.go"
} >zisrnames.go

name=$(basename $(pwd))

GOOS=noos GOARCH=thumb go build -tags $GOTARGET -ldflags "-M $GOMEM -T $GOTEXT" -o $name.elf $@

[ "$IRQNAMES" ] && rm -f zisrnames.go

rm -f $name.hex $name-settings.hex $name.bin
case "$OUT" in
hex)
	arm-none-eabi-objcopy -O ihex $name.elf $name.hex
	;;
bin)
	arm-none-eabi-objcopy -O binary $name.elf $name.bin
	;;
esac
