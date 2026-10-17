# shellcheck shell=bash

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

# Follow upstreams from the given local branch ref (default: current branch).
# Print the remote upstream ref, remote name and destination branch, separated by spaces.
# Git ref and remote names cannot contain spaces. Keep diagnostics on stderr for callers.
git_alias_find_remote_upstream() {
	local base_branch visited_branches upstream_info upstream_branch remote remote_branch
	base_branch=${1:-$(git symbolic-ref --quiet HEAD 2>/dev/null || true)}
	visited_branches=" "

	while :; do
		case "$base_branch" in
		refs/heads/*) ;;
		*)
			COLOR=red git_alias_msg "cannot follow upstream branches from detached HEAD" >&2
			return 1
			;;
		esac

		case "$visited_branches" in
		*" $base_branch "*)
			COLOR=red git_alias_msg "upstream cycle detected at $base_branch" >&2
			return 1
			;;
		esac
		visited_branches="$visited_branches$base_branch "

		upstream_info=$(git for-each-ref --format='%(upstream) %(upstream:remotename) %(upstream:remoteref)' "$base_branch")
		read -r upstream_branch remote remote_branch <<<"$upstream_info"
		if [ -z "$upstream_branch" ]; then
			COLOR=red git_alias_msg "no upstream configured for $base_branch" >&2
			return 1
		fi

		if [ "$remote" != "." ]; then
			printf '%s %s %s\n' "$upstream_branch" "$remote" "${remote_branch#refs/heads/}"
			return 0
		fi
		base_branch=$upstream_branch
	done
}

git_alias_spawn_shell() {
	prompt=$1
	shift

	PS1_EXTRA="$prompt" "$SHELL"
}
