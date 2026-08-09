#!/usr/bin/env bash
# Decides whether a semver prerelease segment denotes a prerelease by matching
# it against a list of keywords, printing `true` or `false`.
#
# Usage: detect-prerelease.sh <prerelease-segment> <keywords-csv>
#
# The prerelease segment is the part of a semver after the `-` (e.g. `rc.1` in
# `v1.2.3-rc.1`), as extracted by a semver parser. An empty segment (a stable
# release such as `v1.2.3`) is never a prerelease.
#
# Matching is a plain case-insensitive substring check: the segment marks a
# prerelease when any keyword appears anywhere in it. The keyword list is
# comma-separated; surrounding whitespace and empty entries are ignored.
#
# Examples (keywords: alpha,beta,rc):
#   detect-prerelease.sh ""      alpha,beta,rc -> false
#   detect-prerelease.sh rc.1    alpha,beta,rc -> true
#   detect-prerelease.sh BETA    alpha,beta,rc -> true
#   detect-prerelease.sh hotfix  alpha,beta,rc -> false

set -euo pipefail

segment="${1:-}"
keywords="${2:-}"

if [ -z "$segment" ]; then
    echo "false"
    exit 0
fi

segment_lc="$(printf '%s' "$segment" | tr '[:upper:]' '[:lower:]')"

IFS=',' read -ra kws <<< "$keywords"
# `${kws[@]+...}` guards against an empty array under `set -u` (bash 3.2).
for kw in ${kws[@]+"${kws[@]}"}; do
    # Trim surrounding whitespace and skip empty entries.
    kw="${kw#"${kw%%[![:space:]]*}"}"
    kw="${kw%"${kw##*[![:space:]]}"}"
    [ -z "$kw" ] && continue

    kw_lc="$(printf '%s' "$kw" | tr '[:upper:]' '[:lower:]')"
    case "$segment_lc" in
        *"$kw_lc"*)
            echo "true"
            exit 0
            ;;
    esac
done

echo "false"
