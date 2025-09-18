#!/usr/bin/env bash

# Set REMOTE_CMD to non-empty string to execute its content on the remote side for all ssh
# connections that don't have 'RemoteCommand' defined in .ssh/config.

# shellcheck disable=SC2016
REMOTE_CMD=${REMOTE_CMD:-''}

HOSTS=$(grep -E 'Host [^*]' ~/.ssh/config | cut -f 2 -d ' ')

format_shell_entry() {
	local ABS
	ABS=$(realpath "$1")
	LNK=""
	if [ "$ABS" != "$1" ]; then
		LNK=" $(tput setaf 6)󰁔 $ABS$(tput sgr0)"
	fi
	echo "L:$1 $(tput setaf 2)$(basename "$1")$(tput sgr0),$1$LNK"
}

ENTRIES=$(
	cur_shell_abs=$(realpath "$SHELL")
	format_shell_entry "$SHELL"
	if [ -f /etc/shells ]; then
		while read -r shell; do
			shell_abs=$(realpath "$shell")
			if [ "$shell_abs" = "$cur_shell_abs" ]; then
				continue
			fi
			echo -n "$shell_abs " && format_shell_entry "$shell"
		done < /etc/shells \
			| sort -k 1,1 -u \
			| cut -d " " -f 2-

	fi
	for host in $HOSTS; do
		vars=$(ssh -G "$host" | grep -E '^(user|hostname|host|port|forwardx11) ' | tr ' ' =)
		eval "$vars"

		X11=""
		# shellcheck disable=SC2154
		if [ "$forwardx11" = yes ]; then
			X11=" (X11)"
		fi
		echo -n "R:$host "
		echo -n "$(tput setaf 3)ssh:$(tput sgr0)$host,"
		# shellcheck disable=SC2154
		echo -n "$(tput sitm)$user$(tput ritm; tput setaf 8)@$(tput sgr0; tput setaf 3)$hostname$(tput sgr0; tput setaf 8):$(tput sgr0)$port"
		echo "$X11"
	done
)

N=$(
	# shellcheck disable=SC2016
	echo "$ENTRIES" | cut -f 2- -d ' ' | column -dt -C left -s, | fzf \
		--ansi \
		--height=100% \
		--delimiter=' ' \
		--accept-nth='{n}' \
		--color=border:'#c39f00' \
		--border double \
		--margin 30%,20% \
		--padding 2,4 \
		--preview-window=top,wrap,border-none \
		--preview ' \
			E=$(sed -n $(({n}+1))p <<< "'"$ENTRIES"'" | cut -f 1 -d " "); \
			IFS=: read -r M ARG <<< "$E"; \
			echo -n "$(tput setaf 4)$(tput sgr0) "; \
			if [ "$M" = R ]; then \
				if ssh -TG "$ARG" | grep -qE "^remotecommand " || [ -z "$REMOTE_CMD" ]; then \
					echo ssh $ARG; \
				else \
					echo ssh $ARG -t "'\''$REMOTE_CMD'\''"; \
				fi; \
				echo; \
				tput setaf 8; \
				ssh -TG "$ARG" | grep -E "^(user|hostname|port|forwardx11|requesttty|remotecommand) "; \
			else \
				echo "$ARG"; \
				echo; \
				tput setaf 8; \
				"$ARG" --version; \
			fi \
		'
)

if [ -z "$N" ]; then
	exit
fi

ENTRY=$(sed -n $((N + 1))p <<< "$ENTRIES" | cut -f 1 -d " ")
IFS=: read -r M ARG <<< "$ENTRY"
if [ "$M" = R ]; then
	if ssh -TG "$ARG" | grep -qE "^remotecommand " || [ -z "$REMOTE_CMD" ]; then
		exec ssh "$ARG"
	else
		exec ssh "$ARG" -t "$REMOTE_CMD"
	fi
else
	exec "$ARG"
fi
