#!/bin/sh

T=alacritty

NAME=$1
shift

if [ "$T" = alacritty ]; then
        EXTRA_OPTS=
        if [ "$TERMINAL_PADDING" = "y" ]; then
                EXTRA_OPTS="-o window.padding.x=30 -o window.padding.y=30"
        fi
        if [ $# -gt 0 ]; then
                # shellcheck disable=SC2086
                alacritty $EXTRA_OPTS --class "$NAME" -e "$@"
        else
                # shellcheck disable=SC2086
                alacritty $EXTRA_OPTS --class "$NAME"
        fi
elif [ "$T" = urxvt ]; then
        if [ $# -gt 0 ]; then
                urxvt -name "$NAME" -e "$@"
        else
                urxvt -name "$NAME"
        fi
else
        xterm -name "$NAME" "$@"
fi
