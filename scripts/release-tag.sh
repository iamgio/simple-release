#!/usr/bin/env bash
# Normalizes and validates the tag of a release that the action itself pushes.
#
# Usage: release-tag.sh <tag>
#
# Examples:
#   release-tag.sh 1.2.3       -> v1.2.3
#   release-tag.sh v1.2.3      -> v1.2.3
#   release-tag.sh 2.0.0-rc.1  -> v2.0.0-rc.1
#
# The leading `v` is optional on input and always present on output, so a
# version typed with or without it yields the same tag. Exits non-zero if the
# version isn't semver (MAJOR.MINOR.PATCH, optional pre-release and build
# metadata), so a typo never reaches the repository as a tag.

set -euo pipefail

tag="${1:-}"

if [ -z "$tag" ]; then
    echo "release-tag.sh: missing tag" >&2
    exit 2
fi

version="${tag#v}"

if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$ ]]; then
    echo "release-tag.sh: '$tag' is not a semver version (expected v?MAJOR.MINOR.PATCH)" >&2
    exit 2
fi

printf 'v%s' "$version"
