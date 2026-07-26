#!/usr/bin/env bash
# Extracts and prints the major-version tag from a semver-style tag.
#
# Usage: major-tag.sh <tag>
#
# Examples:
#   major-tag.sh v1.2.3      -> v1
#   major-tag.sh v2.0.0-rc.1 -> v2
#   major-tag.sh 3.4.5       -> 3
#
# Exits non-zero if the tag doesn't start with an optional `v` followed by a
# digit and a `.` (i.e. it doesn't look like a semver tag).

set -euo pipefail

tag="${1:-}"

if [ -z "$tag" ]; then
    echo "major-tag.sh: missing tag" >&2
    exit 2
fi

if ! [[ "$tag" =~ ^(v?)([0-9]+)\..+$ ]]; then
    echo "major-tag.sh: tag '$tag' does not look like a semver tag (expected v?MAJOR.MINOR.PATCH)" >&2
    exit 2
fi

printf '%s%s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
