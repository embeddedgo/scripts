#!/bin/sh

for d in ../*/devboard/*/examples/*; do
	if [ -d $d ]; then
		echo $d
		cd $d
		if [ -x ../build.sh ]; then
			../build.sh
		elif [ -x ../build-blank.sh ]; then
			../build-blank.sh
		fi
		cd - >/dev/null
	fi
done
