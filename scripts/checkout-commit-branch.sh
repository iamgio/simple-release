#!/usr/bin/env bash
# Attaches HEAD to the branch that the release commit will be pushed to.
#
# Usage: checkout-commit-branch.sh <branch>
#
# Tag-triggered workflows leave `actions/checkout` in a detached HEAD state.
# git-auto-commit-action switches to its `branch` only *after* the release files
# have been rewritten, and git refuses to switch while those files carry
# uncommitted changes ("Your local changes to the following files would be
# overwritten by checkout"). Performing the same switch here — before anything
# touches the working tree — turns the later one into a no-op.
#
# No-op when HEAD already sits on the requested branch, which is the case for
# workflows triggered by a push to that branch.

set -euo pipefail

branch="${1:-}"

if [ -z "$branch" ]; then
    echo "checkout-commit-branch.sh: missing branch" >&2
    exit 2
fi

if [ "$(git rev-parse --abbrev-ref HEAD)" = "$branch" ]; then
    exit 0
fi

# A tag-triggered checkout only fetches the tag ref, so the remote-tracking
# branch has to be fetched before it can be checked out. Fetching without
# `--depth` keeps an existing shallow boundary intact instead of imposing one.
if ! git fetch origin "+refs/heads/$branch:refs/remotes/origin/$branch"; then
    echo "checkout-commit-branch.sh: cannot fetch branch '$branch' from origin" >&2
    exit 1
fi

if ! git checkout "$branch"; then
    echo "checkout-commit-branch.sh: cannot switch to branch '$branch'; the working tree carries changes that conflict with it" >&2
    exit 1
fi
