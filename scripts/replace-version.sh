#!/usr/bin/env bash
# Replaces every occurrence of the previous release version with the new one
# in the given files, as literal text: no regex, no syntax awareness.
#
# Usage: replace-version.sh <old-version> <new-version> <file...>
#
# A leading `v` is stripped from both versions before matching, so bare
# occurrences (`1.2.3`) are replaced directly and `v`-prefixed ones (`v1.2.3`)
# keep their prefix and get the new bare version behind it.

set -euo pipefail

old="${1:-}"
new="${2:-}"

if [ -z "$old" ]; then
    echo "replace-version.sh: missing old version" >&2
    exit 2
fi

if [ -z "$new" ]; then
    echo "replace-version.sh: missing new version" >&2
    exit 2
fi

shift 2

if [ "$#" -eq 0 ]; then
    echo "replace-version.sh: missing file operands" >&2
    exit 2
fi

old="${old#v}"
new="${new#v}"

# Validate everything upfront so a bad path never leaves a partial update.
for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "replace-version.sh: file '$file' does not exist" >&2
        exit 2
    fi
done

for file in "$@"; do
    # The sentinel stops command substitution from eating trailing newlines,
    # so the file's final bytes survive the round-trip.
    content="$(cat "$file"; printf x)"
    content="${content%x}"
    # The pattern is quoted so glob characters in the version stay literal;
    # the replacement must stay unquoted for bash 3.2 (macOS), which would
    # otherwise keep the quotes as literal characters.
    printf '%s' "${content//"$old"/$new}" > "$file"
done
