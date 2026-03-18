#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit

get() {
	INPUT=$1
	FIELD=$2
	jq -r ".nodes[\"$INPUT\"].locked.$FIELD"
}

no_changes=""
INPUTS=$(jq -r '.nodes | keys[]' <../flake.lock | grep -v nixpkgs)
for i in $INPUTS; do
	tp=$(get "$i" "type" <../flake.lock)
	if [ "$tp" != github ]; then
		case "$i" in
		dot-*)
			echo "WARNING: $i source overridden!!!"
			;;
		esac
		continue
	fi
	owner=$(get "$i" owner <../flake.lock)
	[ "$owner" != komar007 ] && continue
	changes=$(PRETTY="format:%H %ai %s" ./flake-input-log.sh "$i" "$1" "$2")
	if [ -n "$changes" ]; then
		echo "changes in $i:"
		echo "$changes"
		echo
	else
		no_changes="$no_changes $i"
	fi
done
if [ -n "$no_changes" ]; then
	no_changes=$(sed -r 's/(.) /\1, /' <<<"$no_changes")
	echo "no changes in$no_changes"
fi
