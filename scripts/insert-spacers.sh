#!/usr/bin/env bash
# Inserts `&nbsp;` spacer lines before every `###` and `####` heading, so
# GitHub renders extra vertical spacing between changelog subsections in the
# release notes without the source markdown having to carry them.
#
# Usage: insert-spacers.sh <input-file> <output-file>
#
# - Existing `&nbsp;` spacer lines (and the blank line immediately after) are
#   stripped first, then fresh spacers are inserted, so the transformation is
#   idempotent regardless of whether the input already has spacers.
# - Lines inside fenced code blocks (``` ... ```) are passed through untouched.
# - Only `###` and `####` are treated as headings; `##` (used for the version
#   header itself) is left alone since it typically doesn't appear inside the
#   extracted per-version notes anyway.

set -euo pipefail

input="${1:-}"
output="${2:-}"

if [ -z "$input" ] || [ -z "$output" ]; then
    echo "insert-spacers.sh: usage: insert-spacers.sh <input-file> <output-file>" >&2
    exit 2
fi

if [ ! -f "$input" ]; then
    echo "insert-spacers.sh: input file '$input' does not exist" >&2
    exit 2
fi

mkdir -p "$(dirname "$output")"

awk '
BEGIN {
    in_code = 0
    first_line = 1
    prev_was_blank = 1
    skip_next_blank = 0
}

# Toggle fenced-code-block state on any line that starts with three backticks.
/^```/ {
    in_code = !in_code
    print
    prev_was_blank = 0
    first_line = 0
    next
}

# Inside a code block, pass everything through untouched.
in_code {
    print
    prev_was_blank = ($0 == "")
    first_line = 0
    next
}

# Strip existing spacer lines; also consume a following blank so we do not
# leave two consecutive blank lines behind.
/^&nbsp;[[:space:]]*$/ {
    skip_next_blank = 1
    next
}

{
    if (skip_next_blank && $0 == "") {
        skip_next_blank = 0
        next
    }
    skip_next_blank = 0
}

# Before every ### or #### heading, emit "[blank]&nbsp;[blank]".
/^### / || /^#### / {
    if (!first_line && !prev_was_blank) print ""
    print "&nbsp;"
    print ""
    print
    prev_was_blank = 0
    first_line = 0
    next
}

{
    print
    prev_was_blank = ($0 == "")
    first_line = 0
}
' < "$input" > "$output"
