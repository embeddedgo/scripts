#!/bin/sh

cd $(dirname $0)

dir=$(pwd)
path="
# added by $dir/scripts/setup.sh
export PATH=\$PATH:$dir
"

echo "Adding $dir to the PATH in the folowing profile files:"
echo

for p in .profile .bash_profile; do
	if [ -f $HOME/$p ]; then
		if grep -q "PATH=.*$dir" $HOME/$p 2>/dev/null; then
			echo "  $HOME/$p - skipped (already added)"
		else
			echo "  $HOME/$p"
			echo "$path" >>$HOME/$p
		fi
	fi
done

echo
echo "Changes take effect on next login. Please relogin."