#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace
}

teardown() {
    teardown_tmp_workspace
}

@test "replaces every occurrence of the old version" {
    printf 'implementation("com.example:lib:1.2.3")\ndocs at /1.2.3/index.html\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/README.md")" = 'implementation("com.example:lib:2.0.0")
docs at /2.0.0/index.html' ]
}

@test "strips leading v from both versions" {
    printf 'version 1.2.3\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "v1.2.3" "v2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/README.md")" = "version 2.0.0" ]
}

@test "updates v-prefixed occurrences too" {
    printf 'download v1.2.3 now\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "v1.2.3" "v2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/README.md")" = "download v2.0.0 now" ]
}

@test "updates multiple files" {
    printf '1.2.3\n' > "$TMP_WORKSPACE/a.txt"
    printf 'v1.2.3\n' > "$TMP_WORKSPACE/b.txt"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0" "$TMP_WORKSPACE/a.txt" "$TMP_WORKSPACE/b.txt"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/a.txt")" = "2.0.0" ]
    [ "$(cat "$TMP_WORKSPACE/b.txt")" = "v2.0.0" ]
}

@test "matches the version literally, not as a regex" {
    printf '1x2y3 stays\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/README.md")" = "1x2y3 stays" ]
}

@test "leaves a file without occurrences untouched" {
    printf 'nothing to see\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/README.md")" = "nothing to see" ]
}

@test "preserves the trailing newline" {
    printf 'version 1.2.3\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    size=$(wc -c < "$TMP_WORKSPACE/README.md" | tr -d ' ')
    [ "$size" = "14" ]
}

@test "preserves the absence of a trailing newline" {
    printf 'version 1.2.3' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    size=$(wc -c < "$TMP_WORKSPACE/README.md" | tr -d ' ')
    [ "$size" = "13" ]
}

@test "handles pre-release versions" {
    printf 'version 1.2.3-rc.1\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3-rc.1" "1.2.3" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 0 ]
    [ "$(cat "$TMP_WORKSPACE/README.md")" = "version 1.2.3" ]
}

@test "fails when a file does not exist" {
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0" "$TMP_WORKSPACE/missing.md"
    [ "$status" -eq 2 ]
    [[ "$output" == *"missing.md"* ]]
}

@test "fails when the old version is empty" {
    printf '1.2.3\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "" "2.0.0" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 2 ]
}

@test "fails when the new version is empty" {
    printf '1.2.3\n' > "$TMP_WORKSPACE/README.md"
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "" "$TMP_WORKSPACE/README.md"
    [ "$status" -eq 2 ]
}

@test "fails when no files are given" {
    run "$SCRIPTS_DIR/replace-version.sh" "1.2.3" "2.0.0"
    [ "$status" -eq 2 ]
}
