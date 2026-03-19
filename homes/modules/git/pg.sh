#!/bin/sh

# Push a single commit to gerrit by cherry-picking it on top of the main branch and pushing.
#
# Features:
# - dirty work dir prevention,
# - interactive conflict fixing if the commit doesn't apply cleanly,
# - a chance to backup result of conflict fixing if it still doesn't apply,
# - immediate exit without making changes when interactive shell is exited with error.

set -e

pg_msg() {
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

if git status --porcelain 2>/dev/null | grep -qE '^(M| M)'; then
	COLOR=red pg_msg 'refusing to push, dirty dir'
	exit 1
fi

IS_GERRIT=$(git remote get-url origin | grep -q gerrit && echo 1 || echo 0)

PREV=$(git rev-parse --abbrev-ref HEAD)
PUSH_BRANCH=push_branch
BASE_BRANCH=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
REMOTE_BRANCH=${BASE_BRANCH#origin/}
if [ "$IS_GERRIT" -eq 1 ]; then
	PUSH_TO="HEAD:refs/for/$REMOTE_BRANCH"
else
	PUSH_TO="HEAD:$REMOTE_BRANCH"
fi

if [ -z "$BASE_BRANCH" ]; then
	COLOR=red pg_msg "cannot resolve origin HEAD locally"
	exit 1
fi

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
	COLOR=red pg_msg "cannot find base branch $BASE_BRANCH locally"
	exit 1
fi

temp_shell() {
	if ! $SHELL; then
		COLOR=red pg_msg 'shell exit with error, about to interrupt pg, type "continue" to continue pg instead of interrupting'
		read -r c
		if [ "$c" = "continue" ]; then
			return 0
		else
			return 1
		fi
	fi
}

git checkout -b "$PUSH_BRANCH" "$BASE_BRANCH"

FAILED=0
if ! git cherry-pick "$1"; then
	git status
	pg_msg "fix conflicts and exit shell"
	PS1_EXTRA="CP FAILED" temp_shell
	git cherry-pick --continue || FAILED=1
fi

if [ "$FAILED" -eq 0 ]; then
	if git push origin "$PUSH_TO"; then
		COLOR=green pg_msg "successfully pushed $1"
	else
		COLOR=red pg_msg "failed to push, backup changes or push yourself to $PUSH_TO and exit shell"
		PS1_EXTRA="PUSH FAILED" temp_shell
	fi
else
	COLOR=red pg_msg "cherry-pick --continue failed, backup changes or push yourself to $PUSH_TO and exit shell"
	PS1_EXTRA="CP CONT FAILED" temp_shell
	git cherry-pick --abort || true
fi
git checkout "$PREV"
git branch -D "$PUSH_BRANCH"
