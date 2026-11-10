#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
}

@test "keeps a v-prefixed tag" {
    run "$SCRIPTS_DIR/release-tag.sh" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$output" = "v1.2.3" ]
}

@test "adds the v prefix to a bare version" {
    run "$SCRIPTS_DIR/release-tag.sh" "1.2.3"
    [ "$status" -eq 0 ]
    [ "$output" = "v1.2.3" ]
}

@test "accepts a pre-release suffix" {
    run "$SCRIPTS_DIR/release-tag.sh" "2.0.0-rc.1"
    [ "$status" -eq 0 ]
    [ "$output" = "v2.0.0-rc.1" ]
}

@test "accepts build metadata" {
    run "$SCRIPTS_DIR/release-tag.sh" "v2.0.0+build.5"
    [ "$status" -eq 0 ]
    [ "$output" = "v2.0.0+build.5" ]
}

@test "fails on empty tag" {
    run "$SCRIPTS_DIR/release-tag.sh" ""
    [ "$status" -eq 2 ]
}

@test "fails on a version without patch" {
    run "$SCRIPTS_DIR/release-tag.sh" "v1.2"
    [ "$status" -eq 2 ]
    [[ "$output" == *"'v1.2'"* ]]
}

@test "fails on a doubled v prefix" {
    run "$SCRIPTS_DIR/release-tag.sh" "vv1.2.3"
    [ "$status" -eq 2 ]
}

@test "fails on a non-version tag" {
    run "$SCRIPTS_DIR/release-tag.sh" "latest"
    [ "$status" -eq 2 ]
}
