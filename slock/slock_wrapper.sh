#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOGFILE="$DIR/slock_wrapper.log"

echo "$(date +%s) lock" >>"$LOGFILE"
xset dpms force off

export XSECURELOCK_SHOW_KEYBOARD_LAYOUT=0
export XSECURELOCK_FONT="JetBrainsMono Nerd Font:pixelsize=30"
export XSECURELOCK_SHOW_DATETIME=1
export XSECURELOCK_SHOW_HOSTNAME=1
export XSECURELOCK_PASSWORD_PROMPT=time_hex

xsecurelock

echo "$(date +%s) unlock" >>"$LOGFILE"
