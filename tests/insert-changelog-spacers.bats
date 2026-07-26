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
    "$SCRIPTS_DIR/insert-changelog-spacers.sh" "$input" "$output"
}

@test "does not insert a spacer before the very first heading" {
    printf '### Added\n\ncontent\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'### Added\n\ncontent'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "inserts spacer before subsequent #### headings" {
    printf '#### Foo\n\ntext\n\n#### Bar\n\nmore\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'#### Foo\n\ntext\n\n&nbsp;\n\n#### Bar\n\nmore'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "inserts spacer between every heading past the first" {
    printf '### Added\n\n#### Foo\n\ntext\n\n### Fixed\n\n#### Bar\n\nmore\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'### Added\n\n&nbsp;\n\n#### Foo\n\ntext\n\n&nbsp;\n\n### Fixed\n\n&nbsp;\n\n#### Bar\n\nmore'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "does not insert spacer before headings inside a fenced code block" {
    printf '### Real heading\n\n```\n### not a heading\n#### also not\n```\n\n#### Another real one\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'### Real heading\n\n```\n### not a heading\n#### also not\n```\n\n&nbsp;\n\n#### Another real one'
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
    expected=$'### Added\n\nSome paragraph with `code` and [links](https://example.com).\n\n- bullet 1\n- bullet 2\n\n> quoted text'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "handles empty input" {
    : > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    [ -f "$TMP_WORKSPACE/out.md" ]
    [ ! -s "$TMP_WORKSPACE/out.md" ]
}

@test "ensures a blank line before the first heading when preceded by text" {
    printf 'text\n#### Foo\n\nmore\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'text\n\n#### Foo\n\nmore'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "passes pre-existing spacer lines through unchanged" {
    printf '### Added\n\n&nbsp;\n\n#### Foo\n' > "$TMP_WORKSPACE/in.md"
    run_insert "$TMP_WORKSPACE/in.md" "$TMP_WORKSPACE/out.md"
    expected=$'### Added\n\n&nbsp;\n\n&nbsp;\n\n#### Foo'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "fails when input file is missing" {
    run "$SCRIPTS_DIR/insert-changelog-spacers.sh" "$TMP_WORKSPACE/missing.md" "$TMP_WORKSPACE/out.md"
    [ "$status" -ne 0 ]
}

@test "fails when args are missing" {
    run "$SCRIPTS_DIR/insert-changelog-spacers.sh"
    [ "$status" -ne 0 ]
}
