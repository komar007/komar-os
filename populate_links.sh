#!/usr/bin/env bash

# The directories below contain legacy (non-home-manager) configuration files
# They must be linked manually or with this script
for d in xorg gdb; do
	for f in "$d"/*; do
		ln -s "$(pwd)/$f" "$HOME/.$(basename "$f")"
	done
done
ln -s "$(pwd)/slock" ~/.slock
