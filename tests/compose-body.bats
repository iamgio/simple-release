#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace
}

teardown() {
    teardown_tmp_workspace
}

@test "writes notes file content when no append file is passed" {
    printf 'Release notes here.\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Release notes here." ]
}

@test "appends the extra file after notes with a blank line separator" {
    printf 'Release notes here.\n' > "$TMP_WORKSPACE/notes.md"
    printf 'Extra footer content.\n' > "$TMP_WORKSPACE/extra.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" "$TMP_WORKSPACE/extra.md"
    [ "$status" -eq 0 ]
    expected=$'Release notes here.\n\nExtra footer content.'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "skips the append file when it does not exist" {
    printf 'Only notes.\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" "$TMP_WORKSPACE/missing.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Only notes." ]
}

@test "skips the append file when path is empty" {
    printf 'Only notes.\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" ""
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Only notes." ]
}

@test "works when notes file is missing (empty body plus append file)" {
    printf 'Only the extras.\n' > "$TMP_WORKSPACE/extra.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/missing.md" "$TMP_WORKSPACE/extra.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Only the extras." ]
}

@test "produces empty file when both inputs missing" {
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/missing1.md" "$TMP_WORKSPACE/missing2.md"
    [ "$status" -eq 0 ]
    [ -f "$TMP_WORKSPACE/out.md" ]
    [ ! -s "$TMP_WORKSPACE/out.md" ]
}

@test "overwrites existing output file" {
    printf 'stale\n' > "$TMP_WORKSPACE/out.md"
    printf 'fresh\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "fresh" ]
}

@test "creates parent directories for output file" {
    printf 'notes\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/nested/deep/out.md" "$TMP_WORKSPACE/notes.md"
    [ "$status" -eq 0 ]
    [ -f "$TMP_WORKSPACE/nested/deep/out.md" ]
}

@test "preserves multi-line structure of the append file" {
    printf 'Notes line 1\nNotes line 2\n' > "$TMP_WORKSPACE/notes.md"
    printf '# Extra\n\n- Alice\n- Bob\n' > "$TMP_WORKSPACE/extra.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" "$TMP_WORKSPACE/extra.md"
    [ "$status" -eq 0 ]
    expected=$'Notes line 1\nNotes line 2\n\n# Extra\n\n- Alice\n- Bob'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}
