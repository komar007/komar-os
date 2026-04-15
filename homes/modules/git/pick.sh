#!/usr/bin/env bash

set -euo pipefail

if [ -n "${GIT_ALIAS_LIB:-}" ]; then
	# shellcheck source=/dev/null
	. "$GIT_ALIAS_LIB"
else
	# shellcheck disable=SC1091
	# shellcheck source=lib.sh
	. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
fi

get_branch_upstream() {
	git for-each-ref --format='%(upstream:short)' "refs/heads/$1"
}

get_branch_upstream_ref() {
	git for-each-ref --format='%(upstream)' "refs/heads/$1"
}

TO_UPSTREAM=0

while [ $# -gt 0 ]; do
	case "$1" in
	--to-upstream)
		TO_UPSTREAM=1
		shift
		;;
	--)
		shift
		break
		;;
	-*)
		echo "Unknown option: $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
	echo "Current HEAD is detached; check out a branch before running this script." >&2
	exit 1
fi

if [ "$TO_UPSTREAM" -eq 1 ]; then
	if [ $# -gt 0 ]; then
		echo "--to-upstream does not accept a source branch argument." >&2
		exit 1
	fi

	if git_alias_has_dirty_worktree; then
		COLOR=red git_alias_msg "Current directory is dirty; refusing to use --to-upstream."
		exit 1
	fi

	UPSTREAM_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
	if [ -z "$UPSTREAM_BRANCH" ]; then
		echo "Current branch $CURRENT_BRANCH has no configured upstream." >&2
		exit 1
	fi

	if ! git show-ref --verify --quiet "refs/heads/$UPSTREAM_BRANCH"; then
		echo "Current branch upstream is not a local branch: $UPSTREAM_BRANCH" >&2
		exit 1
	fi

	git checkout "$UPSTREAM_BRANCH"

	# shellcheck disable=SC2329
	cleanup() {
		git rebase --abort >/dev/null 2>&1 || true
		git checkout "$CURRENT_BRANCH"
	}

	trap cleanup EXIT

	if ! git pick "$CURRENT_BRANCH"; then
		git_alias_msg 'git pick failed; fix conflicts if needed, then exit shell'
		if ! git_alias_spawn_shell 'PICK FAILED'; then
			COLOR=red git_alias_msg 'shell exited with error'
		fi
	fi

	exit 0
fi

CURRENT_BRANCH_REF=$(git rev-parse --symbolic-full-name "$CURRENT_BRANCH")

if [ -n "${1-}" ]; then
	SOURCE_BRANCH=$1
	if ! git rev-parse --verify "$SOURCE_BRANCH" >/dev/null 2>&1; then
		echo "Could not resolve local branch: $SOURCE_BRANCH" >&2
		exit 1
	fi
else
	mapfile -t candidate_branches < <(
		git for-each-ref --format='%(refname:short)' refs/heads |
			while read -r branch; do
				if [ "$(get_branch_upstream_ref "$branch")" = "$CURRENT_BRANCH_REF" ]; then
					printf '%s\n' "$branch"
				fi
			done
	)

	if [ ${#candidate_branches[@]} -eq 0 ]; then
		echo "No local branches found with upstream $CURRENT_BRANCH." >&2
		exit 1
	fi

	if [ ${#candidate_branches[@]} -eq 1 ]; then
		SOURCE_BRANCH=${candidate_branches[0]}
	else
		SOURCE_BRANCH=$(printf '%s\n' "${candidate_branches[@]}" | fzf --prompt='Source branch> ')
		if [ -z "$SOURCE_BRANCH" ]; then
			echo "No branch selected." >&2
			exit 1
		fi
	fi
fi

SOURCE_UPSTREAM=$(get_branch_upstream "$SOURCE_BRANCH")

if [ -z "$SOURCE_UPSTREAM" ]; then
	echo "Branch $SOURCE_BRANCH has no configured upstream." >&2
	exit 1
fi

if ! git rev-parse --verify "$SOURCE_UPSTREAM" >/dev/null 2>&1; then
	echo "Could not resolve upstream for analyzed branch $SOURCE_BRANCH: $SOURCE_UPSTREAM" >&2
	exit 1
fi

conventional_commit_pattern='^[a-z][a-z0-9-]*(\([^)]+\))?(!)?: .+'

declare -A commit_subject=()
declare -A matching_commits=()
declare -a commits=()

while IFS=$'\t' read -r commit subject; do
	commit_subject["$commit"]=$subject
	commits+=("$commit")
	if [[ $subject =~ $conventional_commit_pattern ]]; then
		matching_commits["$commit"]=$subject
	fi
done < <(git log --reverse --format='%H%x09%s' "$SOURCE_UPSTREAM..$SOURCE_BRANCH")

todo_file=$(mktemp)
editor_script=$(mktemp)

cleanup() {
	rm -f "$todo_file" "$editor_script"
}

trap cleanup EXIT

{
	printf '# source branch: %s\n' "$SOURCE_BRANCH"
	for commit in "${commits[@]}"; do
		subject=${commit_subject[$commit]}
		if [[ -v "matching_commits[$commit]" ]]; then
			printf 'pick %s %s\n' "$commit" "$subject"
		else
			printf '# pick %s %s\n' "$commit" "$subject"
		fi
	done
} >"$todo_file"

cat >"$editor_script" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

cp "$TODO_FILE" "$1"

if [ -n "${VISUAL:-}" ]; then
	sh -c '"$@"' sh "$VISUAL" "$1"
elif [ -n "${EDITOR:-}" ]; then
	sh -c '"$@"' sh "$EDITOR" "$1"
else
	editor=$(git var GIT_EDITOR)
	sh -c '"$@"' sh "$editor" "$1"
fi
EOF

chmod +x "$editor_script"
export TODO_FILE="$todo_file"

GIT_SEQUENCE_EDITOR="$editor_script" git rebase -i HEAD
