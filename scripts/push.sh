#!/usr/bin/env bash
# Atomically pushes refs to a remote.
#
# Usage: push.sh <override-server-url> <remote-url> <refspec>...
#
# `actions/checkout` persists its token as an `http.<server-url>/.extraheader`
# Authorization header, which git sends in place of the credentials embedded in
# the remote URL. When <override-server-url> is set (e.g. `https://github.com`),
# that header is reset for this push only, so the remote URL's credentials
# authenticate it, leaving the caller's git config untouched. When empty, the
# persisted credentials keep precedence, and the remote URL's ones are used
# only if checkout persisted none.
#
# `--atomic` makes the remote apply all refspecs or none, so a release commit
# never lands on its branch without its tag (e.g. when the tag already exists).

set -euo pipefail

if [ "$#" -lt 3 ] || [ -z "$2" ]; then
    echo "push.sh: usage: push.sh <override-server-url> <remote-url> <refspec>..." >&2
    exit 2
fi

override_server_url="$1"
remote="$2"
shift 2

config=()
if [ -n "$override_server_url" ]; then
    config=(-c "http.${override_server_url}/.extraheader=")
fi

# The `+` expansion keeps an empty array legal under `set -u` on bash < 4.4.
git ${config[@]+"${config[@]}"} push --atomic "$remote" "$@"
