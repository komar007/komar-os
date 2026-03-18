#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit

INPUT=$1
FROM=${2:-"HEAD"}
TO=${3:-"--unstaged"}

get() {
	FIELD=$1
	jq -r ".nodes[\"$INPUT\"].locked.$FIELD"
}

get_flake_lock() {
	if [ "$1" = "--unstaged" ]; then
		cat ../flake.lock
	elif [ "$1" = "--staged" ]; then
		git show :../flake.lock
	else
		git show "$1":../flake.lock
	fi
}

get_github_url() {
	FLAKE_REV=$1
	FLAKE=$(get_flake_lock "$FLAKE_REV")
	echo "https://github.com/$(get owner <<<"$FLAKE")/$(get repo <<<"$FLAKE")"
}

INPUT_FROM=$(get_flake_lock "$FROM" | get rev)
INPUT_TO=$(get_flake_lock "$TO" | get rev)

if [ "$INPUT_FROM" = null ] || [ "$INPUT_TO" = null ]; then
	echo "$INPUT: wrong type of input, missing revision" >/dev/stderr
	exit 1
fi

PRETTY=${PRETTY:-oneline}

URL=$(get_github_url "$FROM")
T=$(mktemp -d)
git clone -q --bare "$URL" "$T"
# shellcheck disable=SC2086
git -C "$T" log --pretty="$PRETTY" "$INPUT_FROM..$INPUT_TO"
rm -fr "$T"
