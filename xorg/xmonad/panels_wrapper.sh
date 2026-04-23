#!/usr/bin/env bash

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# clean up xmonad's mess
SELF=$BASHPID
# shellcheck disable=SC2046
kill -9 $(pgrep -f panels_wrapper.sh | grep -v $SELF)

while true; do
	"$DIR"/panels_launch.sh
	sleep 1
done
