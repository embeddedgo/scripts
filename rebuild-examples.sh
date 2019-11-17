#!/bin/sh

for d in ../*/devboard/*/examples/*; do
	if [ -d $d ]; then
		cd $d
		../build.sh
		cd - >/dev/null
	fi
done