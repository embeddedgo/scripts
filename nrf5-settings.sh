#!/bin/sh

set -e

name=$(basename $(pwd))

nrfutil settings generate --family $family --application $name.hex --application-version $appversion --bootloader-version $bootversion --bl-settings-version 1 $name-settings.hex >/dev/null