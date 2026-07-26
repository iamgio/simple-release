#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace
}

teardown() {
    teardown_tmp_workspace
}

@test "strips leading v and writes to file" {
    run "$SCRIPTS_DIR/bump-version.sh" "$TMP_WORKSPACE/version.txt" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/version.txt")" = "1.2.3" ]
}

@test "leaves tag without v prefix untouched" {
    run "$SCRIPTS_DIR/bump-version.sh" "$TMP_WORKSPACE/version.txt" "2.0.0"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/version.txt")" = "2.0.0" ]
}

@test "keeps v prefix when --keep-v is passed" {
    run "$SCRIPTS_DIR/bump-version.sh" --keep-v "$TMP_WORKSPACE/version.txt" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/version.txt")" = "v1.2.3" ]
}

@test "writes without trailing newline" {
    run "$SCRIPTS_DIR/bump-version.sh" "$TMP_WORKSPACE/version.txt" "v1.0.0"
    [ "$status" -eq 0 ]
    # File size should exactly equal the string length (5), no extra newline.
    size=$(wc -c < "$TMP_WORKSPACE/version.txt" | tr -d ' ')
    [ "$size" = "5" ]
}

@test "creates parent directories if needed" {
    run "$SCRIPTS_DIR/bump-version.sh" "$TMP_WORKSPACE/nested/dir/version.txt" "v1.0.0"
    [ "$status" -eq 0 ]
    [ -f "$TMP_WORKSPACE/nested/dir/version.txt" ]
}

@test "fails when file path is empty" {
    run "$SCRIPTS_DIR/bump-version.sh" "" "v1.0.0"
    [ "$status" -ne 0 ]
}

@test "fails when tag is empty" {
    run "$SCRIPTS_DIR/bump-version.sh" "$TMP_WORKSPACE/version.txt" ""
    [ "$status" -ne 0 ]
}

@test "handles semver with pre-release suffix" {
    run "$SCRIPTS_DIR/bump-version.sh" "$TMP_WORKSPACE/version.txt" "v1.0.0-rc.1"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/version.txt")" = "1.0.0-rc.1" ]
}
