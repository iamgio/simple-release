#!/usr/bin/env bash
# Prints the closest v-prefixed version tag (e.g. `v1.2.3`) reachable from the
# parent of <tag>, i.e. the release that came before it. Prints nothing when
# there is none.
#
# Usage: previous-tag.sh <tag>

set -euo pipefail

tag="${1:-}"

if [ -z "$tag" ]; then
    echo "previous-tag.sh: missing tag" >&2
    exit 2
fi

if ! git rev-parse --quiet --verify "${tag}^{commit}" >/dev/null; then
    echo "previous-tag.sh: tag '$tag' does not exist" >&2
    exit 2
fi

# --match keeps everything but `v<digit>`-style tags out of the lookup, most
# notably rolling tags such as a `latest` devbuild tag.
git describe --tags --abbrev=0 --match 'v[0-9]*' "${tag}^" 2>/dev/null || true
