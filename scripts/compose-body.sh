#!/usr/bin/env bash
# Composes a release body file from a notes file and an optional sponsors file.
#
# Usage: compose-body.sh <output-file> <notes-file> [sponsors-file]
#
# - Writes the notes file content into the output file.
# - If a sponsors file is provided and exists, its content is appended after a
#   blank-line separator.
# - Missing input files are treated as empty, so callers can safely pass paths
#   for optional pieces without pre-checking existence.

set -euo pipefail

out="${1:-}"
notes="${2:-}"
sponsors="${3:-}"

if [ -z "$out" ]; then
    echo "compose-body.sh: missing output file path" >&2
    exit 2
fi

mkdir -p "$(dirname "$out")"
: > "$out"

if [ -n "$notes" ] && [ -f "$notes" ]; then
    cat "$notes" >> "$out"
fi

if [ -n "$sponsors" ] && [ -f "$sponsors" ]; then
    # Ensure a blank line between sections only if there's existing content.
    if [ -s "$out" ]; then
        # Guarantee the notes end with a newline before the blank separator.
        if [ "$(tail -c1 "$out" | wc -l | tr -d ' ')" = "0" ]; then
            printf '\n' >> "$out"
        fi
        printf '\n' >> "$out"
    fi
    cat "$sponsors" >> "$out"
fi
