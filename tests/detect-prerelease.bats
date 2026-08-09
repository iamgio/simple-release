#!/usr/bin/env bats

load 'test_helper'

DEFAULT_KEYWORDS='alpha,beta,rc,pre,preview,snapshot,nightly,dev'

setup() {
    setup_scripts_dir
}

@test "empty segment (stable release) is not a prerelease" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "" "$DEFAULT_KEYWORDS"
    [ "$status" -eq 0 ]
    [ "$output" = "false" ]
}

@test "matches rc" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "rc.1" "$DEFAULT_KEYWORDS"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "matches alpha" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "alpha.2" "$DEFAULT_KEYWORDS"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "matches beta" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "beta" "$DEFAULT_KEYWORDS"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "matches nightly" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "nightly" "$DEFAULT_KEYWORDS"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "matching is case-insensitive" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "BETA" "$DEFAULT_KEYWORDS"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "non-keyword segment is not a prerelease" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "hotfix" "$DEFAULT_KEYWORDS"
    [ "$status" -eq 0 ]
    [ "$output" = "false" ]
}

@test "respects a narrowed keyword list" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "dev" "alpha,beta,rc"
    [ "$status" -eq 0 ]
    [ "$output" = "false" ]
}

@test "empty keyword list never matches" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "rc.1" ""
    [ "$status" -eq 0 ]
    [ "$output" = "false" ]
}

@test "ignores whitespace and empty entries in the keyword list" {
    run "$SCRIPTS_DIR/detect-prerelease.sh" "rc.1" " , rc , "
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}
