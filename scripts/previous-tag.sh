#!/usr/bin/env bash
# Prints the highest v-prefixed version tag (e.g. `v1.2.3`) whose version is
# lower than <tag>'s, i.e. the release that came before it. Prints nothing
# when there is none.
#
# Version order, not history, decides: tags in the wild don't always sit on
# the release train (e.g. a tag pointing at an old commit that `git describe`
# would misreport as the closest reachable one).
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

# The pattern keeps everything but `v<digit>`-style tags out of the lookup,
# most notably rolling tags such as a `latest` devbuild tag. The list is
# version-sorted descending, so the previous release is the entry right after
# the current tag; nothing is printed when the current tag closes the list or
# is not v-prefixed itself.
git tag --list 'v[0-9]*' --sort=-v:refname | awk -v current="$tag" '
    found { print; exit }
    $0 == current { found = 1 }
'
