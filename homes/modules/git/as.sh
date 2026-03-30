#!/bin/sh

if [ -n "${1-}" ]; then
	BASE="$1"
elif BASE=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null); then
	:
else
	BASE=$(
		# shellcheck disable=SC2046
		git log --format='%H' HEAD^ |
			grep -m 1 --color=never -F $(git branch --format='-e %(objectname)')
	)
fi

if [ -z "$BASE" ]; then
	echo "CANNOT FIND BASE, specify manually" 2>/dev/stderr
	exit 1
fi

git rebase -i --autosquash "$BASE"
