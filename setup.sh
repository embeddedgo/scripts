#!/bin/sh

cd $(dirname $0)

dir=$(pwd)
gobin=$dir/go/bin
path="
# added by $dir/setup.sh
export PATH=\$PATH:$gobin
"

if [ ! -d $gobin ]; then
	echo "There is no $gobin directory."
	exit 1
fi

echo "Adding $gobin to the PATH in profile files:"
echo

for p in .profile .bash_profile; do
	if [ -f $HOME/$p ]; then
		if grep -q "$gobin" $HOME/$p 2>/dev/null; then
			echo "  $HOME/$p - skipped (already added)"
		else
			echo "  $HOME/$p"
			echo "$path" >>$HOME/$p
		fi
	fi
done

echo
echo "Changes take effect on next login. Please relogin."