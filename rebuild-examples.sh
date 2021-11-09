#!/bin/sh

for d in ../*/devboard/*/examples/*; do
	if [ -d $d ]; then
		echo $d
		cd $d
		if [ -f main.go ]; then
			if [ -x ../build.sh ]; then
				../build.sh
			elif [ -x ../build-blank.sh ]; then
				../build-blank.sh
			fi
		fi
		cd - >/dev/null
	fi
done
