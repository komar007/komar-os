#!/bin/sh

if [ -z "$1" ]; then
	exit
fi
PROJ="$HOME/repos/$1"
if [ "$1" = "config" ]; then
	echo "$HOME/repos/komar-os"
elif [ -d "$PROJ" ]; then
	echo "${PROJ}"
fi
