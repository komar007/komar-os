#!/usr/bin/env bash

set -e

best_matches() {
	input="$1"
	shift
	for pattern in "$@"; do
		pat="^${pattern}\$"
		if grep -m 1 -E "$pat" <<<"$input"; then
			break
		fi
	done
}

if [ -n "${1:-}" ]; then
	target="$1"
else
	targets=$(xclip -selection clipboard -t TARGETS -o | grep -vE '^[A-Z_]+$')
	if [ -z "$targets" ]; then
		echo "no targets available" >&2
		exit 1
	fi
	target="$(
		best_matches "$targets" \
			image/png \
			image/jpeg \
			image/.* \
			text/html \
			text/.*
	)"
	if [ -z "$target" ]; then
		echo "no suitable targets available: $(tr '\n' ' ' <<<"$targets")" >&2
		target=$(head -n 1 <<<"$targets")
		echo "choosing $target" >&2
	fi
fi

if [ -z "$target" ]; then
	xclip -selection clipboard -o
else
	xclip -selection clipboard -t "$target" -o
fi
