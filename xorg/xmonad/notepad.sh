#!/bin/bash

DIR=~/.notepad
LOG="$DIR"/$(date +%Y-%m-%d_%H:%M:%S)

mkdir -p "$DIR"
rlwrap cat >"$LOG"
