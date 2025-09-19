#!/usr/bin/env bash

# Environment variables:
#
# REMOTE_CMD
# Set to non-empty string to execute its content on the remote side for all ssh
# connections that don't have 'RemoteCommand' defined in .ssh/config.
#
# PAUSE_AFTER_SSH_FAIL
# Set to 0 to disable pausing and waiting for return key after unsuccessful ssh
# exit status
#
set -e

REMOTE_CMD=${REMOTE_CMD:-''}
PAUSE_AFTER_SSH_FAIL=${PAUSE_AFTER_SSH_FAIL:-1}

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

ENTRY_REQUIRED_SSH_VARS="user hostname host port forwardx11 proxyjump"
format_remote_host_entry() {
	# shellcheck disable=SC2086
	local $ENTRY_REQUIRED_SSH_VARS
	for var in $ENTRY_REQUIRED_SSH_VARS; do
		declare -n V=$var
		# shellcheck disable=SC2034
		V=""
	done
	eval "$1"

	echo -n "R:$host "
	echo -n "$(tput setaf 3)ssh:$(tput sgr0)$host,"
	# shellcheck disable=SC2154
	echo -n "$(tput sitm)$user$(
		tput ritm
		tput setaf 8
	)@$(
		tput sgr0
		tput setaf 3
	)$hostname$(
		tput sgr0
		tput setaf 8
	):$(tput sgr0)$port"
	if [ -n "$proxyjump" ]; then
		echo -n " via $(tput sitm) $proxyjump$(tput ritm)"
	fi
	# shellcheck disable=SC2154
	if [ "$forwardx11" = yes ]; then
		echo -n " (X11)"
	fi
	echo
}

# L:<shell-cmd> <fzf-column-1>,<fzf-column-2>
# R:<ssh-host-name> <fzf-column-1>,<fzf-column-2>
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
		vars=$(ssh -G "$host" | grep -E "^(${ENTRY_REQUIRED_SSH_VARS// /|}) " | tr ' ' =)
		format_remote_host_entry "$vars"
	done
)

N=$(
	# columnize the <fzf-column-1>,<fzf-column-2> part
	ENTRIES_FZF=$(echo "$ENTRIES" | cut -f 2- -d ' ' | column -dt -C left -s,)
	# shellcheck disable=SC2016
	fzf \
		--ansi \
		--height=100% \
		--delimiter=' ' \
		--accept-nth='{n}' \
		--color='bg:#222222,current-bg:#555555,gutter:#333333' \
		--highlight-line \
		--border top \
		--border-label "$(yes ' ' | head -n "$(tput cols)" | tr -d '\n')" \
		--margin 30%,20% \
		--algo v1 \
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
				ssh -TG "$ARG" | grep -E "^(user|hostname|port|forwardx11|requesttty|remotecommand|proxyjump) "; \
			else \
				echo "$ARG"; \
				echo; \
				tput setaf 8; \
				"$ARG" --version; \
			fi \
		' \
		<<< "$ENTRIES_FZF"
)

if [ -z "$N" ]; then
	exit
fi

ENTRY=$(sed -n $((N + 1))p <<< "$ENTRIES" | cut -f 1 -d " ")
IFS=: read -r M ARG <<< "$ENTRY"
if [ "$M" = R ]; then
	SSH_STATUS=0
	if ssh -TG "$ARG" | grep -qE "^remotecommand " || [ -z "$REMOTE_CMD" ]; then
		if ! ssh "$ARG"; then
			SSH_STATUS=1
		fi
	else
		if ! ssh "$ARG" -t "$REMOTE_CMD"; then
			SSH_STATUS=1
		fi
	fi
	# shellcheck disable=SC2181
	if [ "$SSH_STATUS" -ne 0 ] && [ "$PAUSE_AFTER_SSH_FAIL" = 1 ]; then
		read -r -p "$(tput setaf 1)ssh failed, press return...$(tput sgr0)"
		exit "$SSH_STATUS"
	fi
else
	exec "$ARG"
fi
