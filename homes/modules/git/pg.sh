#!/bin/sh

# Push a single commit to gerrit by cherry-picking it on top of the main branch and pushing.
#
# Features:
# - dirty work dir prevention,
# - interactive conflict fixing if the commit doesn't apply cleanly,
# - a chance to backup result of conflict fixing if it still doesn't apply,
# - immediate exit without making changes when interactive shell is exited with error.

set -e

if [ -n "${GIT_ALIAS_LIB:-}" ]; then
	# shellcheck source=/dev/null
	. "$GIT_ALIAS_LIB"
else
	# shellcheck disable=SC1091
	# shellcheck source=lib.sh
	. "$(dirname "$0")/lib.sh"
fi

if git_alias_has_dirty_worktree; then
	COLOR=red git_alias_msg 'refusing to push, dirty dir'
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
	COLOR=red git_alias_msg "cannot resolve origin HEAD locally"
	exit 1
fi

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
	COLOR=red git_alias_msg "cannot find base branch $BASE_BRANCH locally"
	exit 1
fi

temp_shell() {
	if ! git_alias_spawn_shell "${PS1_EXTRA:-}"; then
		COLOR=red git_alias_msg 'shell exit with error, about to interrupt pg, type "continue" to continue pg instead of interrupting'
		read -r c
		if [ "$c" = "continue" ]; then
			return 0
		else
			return 1
		fi
	fi
}

if [ "$#" -eq 0 ]; then
	if [ "$PREV" = "HEAD" ]; then
		COLOR=red git_alias_msg 'cannot use git pick from detached HEAD; pass a commit instead'
		exit 1
	fi

	APPLY_MODE=pick
	APPLY_TARGET=$PREV
	APPLY_FAILED_PROMPT="PICK FAILED"
	CONTINUE_FAILED_PROMPT="PICK CONT FAILED"
	CONTINUE_FAILED_MESSAGE="git pick --continue failed, backup changes or push yourself to $PUSH_TO and exit shell"
	PUSH_SOURCE="partial $PREV"
else
	APPLY_MODE=cherry-pick
	APPLY_TARGET=$1
	APPLY_FAILED_PROMPT="CP FAILED"
	CONTINUE_FAILED_PROMPT="CP CONT FAILED"
	CONTINUE_FAILED_MESSAGE="git cherry-pick --continue failed, backup changes or push yourself to $PUSH_TO and exit shell"
	PUSH_SOURCE="$1"
fi

git checkout -b "$PUSH_BRANCH" "$BASE_BRANCH"

FAILED=0
if ! git "$APPLY_MODE" "$APPLY_TARGET"; then
	git status
	git_alias_msg "fix conflicts and exit shell"
	PS1_EXTRA="$APPLY_FAILED_PROMPT" temp_shell
	git "$APPLY_MODE" --continue || FAILED=1
fi

if [ "$FAILED" -eq 0 ]; then
	if git push origin "$PUSH_TO"; then
		COLOR=green git_alias_msg "successfully pushed $PUSH_SOURCE"
	else
		COLOR=red git_alias_msg "failed to push, backup changes or push yourself to $PUSH_TO and exit shell"
		PS1_EXTRA="PUSH FAILED" temp_shell
	fi
else
	COLOR=red git_alias_msg "$CONTINUE_FAILED_MESSAGE"
	PS1_EXTRA="$CONTINUE_FAILED_PROMPT" temp_shell
	git "$APPLY_MODE" --abort || true
fi
git checkout "$PREV"
git branch -D "$PUSH_BRANCH"
