#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -a ~/.desktop_type ]]; then
	CONFIG=`cat ~/.desktop_type`
elif [[ -d /sys/class/power_supply/BAT1/ ]]; then
	CONFIG=laptop
else
	CONFIG=desktop
fi

killall -9 xmobar dzen2 2> /dev/null

PIDS=/tmp/panels.pids.$RANDOM

FIFO=/tmp/xmobar_panel_fifo

while [ ! -p "$FIFO" ]; do
    sleep 1
done

FN=$(cpp -P -I"$DIR" - <<< '#include "xmonad.rc"'$'\n''DZEN2_FONT')
HEIGHT=$(cpp -P -I"$DIR" - <<< '#include "xmonad.rc"'$'\n''HEIGHT')

if [[ $CONFIG == desktop ]]; then
    DZEN_X=1920
elif [[ $CONFIG == work ]]; then
    DZEN_X=1200
elif [[ $CONFIG == laptop ]]; then
    DZEN_X=400
fi

# in case cat dies because of broken pipe
while true; do
	cat "$FIFO"
done | dzen2 -bg black -h $HEIGHT -x "$DZEN_X" -ta l -fn "$FN" &
echo $! > $PIDS
sleep 0.1
if [[ $CONFIG == desktop ]]; then
    ICON_ROOT="$HOME/.xmonad/dzen2_img_large/"
    cpp -P -I"$DIR" -DICON_ROOT=\"$ICON_ROOT\" -DCONFIG_DESKTOP -DPOS=0    -DWIDTH=1920 ~/.xmonad/xmobar-info.in               > /tmp/xmobar-info-desktop
    cpp -P -I"$DIR" -DICON_ROOT=\"$ICON_ROOT\" -DCONFIG_DESKTOP -DPOS=3440 -DWIDTH=400  ~/.xmonad/xmobar-clock.in              > /tmp/xmobar-clock
    xmobar /tmp/xmobar-info-desktop &
    echo $! >> $PIDS
    xmobar /tmp/xmobar-clock &
    echo $! >> $PIDS
elif [[ $CONFIG == work ]]; then
    ICON_ROOT="$HOME/.xmonad/dzen2_img_small/"
    cpp -P -I"$DIR" -DICON_ROOT=\"$ICON_ROOT\" -DCONFIG_WORK    -DPOS=0    -DWIDTH=1000 ~/.xmonad/xmobar-info.in               > /tmp/xmobar-info-work
    cpp -P -I"$DIR" -DICON_ROOT=\"$ICON_ROOT\" -DCONFIG_WORK    -DPOS=1000 -DWIDTH=200 -DSIDE_LEFT   ~/.xmonad/xmobar-clock.in > /tmp/xmobar-clock1
    cpp -P -I"$DIR" -DICON_ROOT=\"$ICON_ROOT\" -DCONFIG_WORK    -DPOS=2600 -DWIDTH=520 -DSIDE_RIGHT  ~/.xmonad/xmobar-clock.in > /tmp/xmobar-clock2
    xmobar /tmp/xmobar-info-work &
    echo $! >> $PIDS
    xmobar /tmp/xmobar-clock1 &
    echo $! >> $PIDS
    xmobar /tmp/xmobar-clock2 &
    echo $! >> $PIDS
elif [[ $CONFIG == laptop ]]; then
    ICON_ROOT="$HOME/.xmonad/dzen2_img_large/"
    cpp -P -I"$DIR" -DICON_ROOT=\"$ICON_ROOT\" -DCONFIG_LAPTOP  -DPOS=0    -DWIDTH=400  ~/.xmonad/xmobar-info.in               > /tmp/xmobar-info-laptop
    cpp -P -I"$DIR" -DICON_ROOT=\"$ICON_ROOT\" -DCONFIG_LAPTOP  -DPOS=1856 -DWIDTH=400  ~/.xmonad/xmobar-clock.in              > /tmp/xmobar-clock
    xmobar /tmp/xmobar-info-laptop &
    echo $! >> $PIDS
    xmobar /tmp/xmobar-clock &
    echo $! >> $PIDS
fi
cat

