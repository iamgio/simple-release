#!/usr/bin/env bash
# Inserts `&nbsp;` spacer lines between `###` and `####` headings, so GitHub
# renders extra vertical spacing between changelog subsections in the release
# notes without the source markdown having to carry them.
#
# Usage: insert-spacers.sh <input-file> <output-file>
#
# - A spacer is inserted *before* every `###`/`####` heading except the very
#   first one, so the release notes never start with a stray `&nbsp;` line.
# - Lines inside fenced code blocks (``` ... ```) are passed through untouched.
# - Any content already in the input is preserved verbatim (no stripping of
#   pre-existing spacers), so callers should feed clean input.

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
    first_heading = 1
    first_line = 1
    prev_was_blank = 1
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

# Headings: insert a spacer before every one except the very first.
/^### / || /^#### / {
    if (first_heading) {
        if (!first_line && !prev_was_blank) print ""
        print
        first_heading = 0
    } else {
        if (!prev_was_blank) print ""
        print "&nbsp;"
        print ""
        print
    }
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
