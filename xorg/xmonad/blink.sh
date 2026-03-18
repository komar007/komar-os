#!/bin/bash

rm -f /tmp/noblink

while [ true ]; do
	for i in $(seq 1 1 3); do
		xset led 3
		sleep 0.1
		xset -led 3
		sleep 0.2
	done
	if [ -f /tmp/noblink ]; then
		break
	fi
	sleep 1.1
done
