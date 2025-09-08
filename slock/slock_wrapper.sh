#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LOGFILE="$DIR/slock_wrapper.log"

echo "$(date +%s) lock"   >> "$LOGFILE"
xset dpms force off

XSECURELOCK_SHOW_KEYBOARD_LAYOUT=0 \
XSECURELOCK_FONT="JetBrainsMono Nerd Font:pixelsize=30" \
XSECURELOCK_SHOW_DATETIME=1 \
XSECURELOCK_SHOW_HOSTNAME=1 \
XSECURELOCK_PASSWORD_PROMPT=time_hex \
	xsecurelock

echo "$(date +%s) unlock" >> "$LOGFILE"
