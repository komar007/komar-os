#!/usr/bin/env bash

FIFO=/tmp/xmobar_panel_fifo

if [ ! -p "$FIFO" ]; then
	rm -fr "$FIFO"
	mkfifo "$FIFO"
fi
while true; do
	cat >$FIFO
	sleep 1
done
