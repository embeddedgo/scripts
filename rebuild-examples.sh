#!/bin/sh

for d in ../*/devboard/*/examples/* ../*/devboard/*/module/*/examples/*; do
	if [ -d $d ]; then
		echo $d
		cd $d
		if [ -f main.go ]; then
			if [ -x ../build-blank.sh ]; then
				../build-blank.sh
			elif [ -x ../build.sh ]; then
				../build.sh
			else
				emgo build
			fi
		fi
		cd - >/dev/null
	fi
done
