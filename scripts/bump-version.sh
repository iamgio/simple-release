#!/usr/bin/env bash
# Writes a version string to a file, optionally stripping a leading `v`.
#
# Usage: bump-version.sh [--keep-v] <version-file> <tag>
#
# By default a leading `v` is removed (matching common tag conventions such as
# `v1.2.3`). Pass `--keep-v` to preserve the original tag verbatim.
# The file is written without a trailing newline so tools consuming it (e.g.
# Gradle) do not need to trim whitespace.

set -euo pipefail

strip_v=1
if [ "${1:-}" = "--keep-v" ]; then
    strip_v=0
    shift
fi

file="${1:-}"
tag="${2:-}"

if [ -z "$file" ]; then
    echo "bump-version.sh: missing version file path" >&2
    exit 2
fi

if [ -z "$tag" ]; then
    echo "bump-version.sh: missing tag" >&2
    exit 2
fi

version="$tag"
if [ "$strip_v" -eq 1 ]; then
    version="${tag#v}"
fi

mkdir -p "$(dirname "$file")"
printf '%s' "$version" > "$file"
