#!/usr/bin/env bash

# The directories below contain legacy (non-home-manager) configuration files
# They must be linked manually or with this script
for f in xorg/*; do
	ln -s "$(pwd)/$f" "$HOME/.$(basename "$f")"
done
ln -s "$(pwd)/slock" ~/.slock
