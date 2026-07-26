#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace
}

teardown() {
    teardown_tmp_workspace
}

@test "writes notes file content when no sponsors" {
    printf 'Release notes here.\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Release notes here." ]
}

@test "appends sponsors after notes with blank line separator" {
    printf 'Release notes here.\n' > "$TMP_WORKSPACE/notes.md"
    printf 'Thanks to sponsors!\n' > "$TMP_WORKSPACE/sponsors.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" "$TMP_WORKSPACE/sponsors.md"
    [ "$status" -eq 0 ]
    expected=$'Release notes here.\n\nThanks to sponsors!'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}

@test "skips sponsors when file does not exist" {
    printf 'Only notes.\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" "$TMP_WORKSPACE/missing.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Only notes." ]
}

@test "skips sponsors when path is empty" {
    printf 'Only notes.\n' > "$TMP_WORKSPACE/notes.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" ""
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Only notes." ]
}

@test "works when notes file is missing (empty body plus sponsors)" {
    printf 'Sponsors only.\n' > "$TMP_WORKSPACE/sponsors.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/missing.md" "$TMP_WORKSPACE/sponsors.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "Sponsors only." ]
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

@test "handles multi-line sponsors preserving structure" {
    printf 'Notes line 1\nNotes line 2\n' > "$TMP_WORKSPACE/notes.md"
    printf '# Sponsors\n\n- Alice\n- Bob\n' > "$TMP_WORKSPACE/sponsors.md"
    run "$SCRIPTS_DIR/compose-body.sh" "$TMP_WORKSPACE/out.md" "$TMP_WORKSPACE/notes.md" "$TMP_WORKSPACE/sponsors.md"
    [ "$status" -eq 0 ]
    expected=$'Notes line 1\nNotes line 2\n\n# Sponsors\n\n- Alice\n- Bob'
    [ "$(cat "$TMP_WORKSPACE/out.md")" = "$expected" ]
}
