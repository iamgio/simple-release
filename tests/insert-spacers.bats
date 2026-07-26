#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace
}

teardown() {
    teardown_tmp_workspace
}

run_insert() {
    local input="$1"
    local output="$2"
    "$SCRIPTS_DIR/insert-spacers.sh" "$input" "$output"
}

@test "inserts spacer before a ### heading at start of file" {
    printf '### Added\n\ncontent\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'&nbsp;\n\n### Added\n\ncontent'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "inserts spacer before a #### heading in the middle" {
    printf 'intro\n\n#### Foo\n\ncontent\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'intro\n\n&nbsp;\n\n#### Foo\n\ncontent'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "inserts spacer before consecutive headings" {
    printf '### Added\n\n#### Foo\n\ntext\n\n### Fixed\n\n#### Bar\n\nmore\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'&nbsp;\n\n### Added\n\n&nbsp;\n\n#### Foo\n\ntext\n\n&nbsp;\n\n### Fixed\n\n&nbsp;\n\n#### Bar\n\nmore'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "removes existing &nbsp; spacer and does not duplicate" {
    printf '### Added\n\n&nbsp;\n\n#### Foo\n\ntext\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'&nbsp;\n\n### Added\n\n&nbsp;\n\n#### Foo\n\ntext'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "does not insert spacer before headings inside a fenced code block" {
    printf '### Real heading\n\n```\n### not a heading\n#### also not\n```\n\n#### Another real one\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'&nbsp;\n\n### Real heading\n\n```\n### not a heading\n#### also not\n```\n\n&nbsp;\n\n#### Another real one'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "does not insert before ## (only ### and ####)" {
    printf '## Version\n\ncontent\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'## Version\n\ncontent'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "leaves body content untouched" {
    input=$'### Added\n\nSome paragraph with `code` and [links](https://example.com).\n\n- bullet 1\n- bullet 2\n\n> quoted text\n'
    printf '%s' "$input" > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'&nbsp;\n\n### Added\n\nSome paragraph with `code` and [links](https://example.com).\n\n- bullet 1\n- bullet 2\n\n> quoted text'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "handles empty input" {
    : > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    [ -f "$TMP_WORKSPACE/out.md" ]
    [ ! -s "$TMP_WORKSPACE/out.md" ]
}

@test "handles heading with no blank line before it" {
    printf 'text\n#### Foo\n\nmore\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'text\n\n&nbsp;\n\n#### Foo\n\nmore'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "removes existing spacer even when followed by another heading immediately" {
    printf '&nbsp;\n\n### Added\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'&nbsp;\n\n### Added'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "fails when input file is missing" {
    run "$SCRIPTS_DIR/insert-spacers.sh" "$TMP_WORKSPACE/missing.md" "$TMP_WORKSPACE/out.md"
    [ "$status" -ne 0 ]
}

@test "fails when args are missing" {
    run "$SCRIPTS_DIR/insert-spacers.sh"
    [ "$status" -ne 0 ]
}
