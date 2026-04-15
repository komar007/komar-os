git_alias_msg() {
	case "${COLOR:-blue}" in
	green)
		seed=63
		;;
	red)
		seed=73
		;;
	blue)
		seed=100
		;;
	esac

	if [ -n "${seed:-}" ]; then
		colorize="lolcat -S $seed -p 10"
	else
		colorize="cat"
	fi

	echo "$@" | cowsay -W 79 | $colorize 2>/dev/null
}

git_alias_has_dirty_worktree() {
	git status --porcelain 2>/dev/null | grep -qE '^(M| M)'
}

git_alias_spawn_shell() {
	prompt=$1
	shift

	PS1_EXTRA="$prompt" "$SHELL"
}
