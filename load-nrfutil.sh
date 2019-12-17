#!/bin/sh

set -e

name=$(basename $(pwd))

if [ $# -eq 0 ]; then
	nrfutil pkg generate --hw-version $hw --sd-req $sdreq --debug-mode --application $name.hex $name.zip
else
	sdid=$(eval echo "\$$(echo $1 |tr '.' '_')")
	nrfutil pkg generate --hw-version $hw --sd-req 0x00 --sd-id "$sdid" --debug-mode --application $name.hex --softdevice $1 $name.zip
fi |grep -v '^|'

nrfutil dfu $dfu -p $port -b 115200 -pkg $name.zip
rm -f $name.zip
