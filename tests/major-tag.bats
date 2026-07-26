#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
}

@test "extracts v-prefixed major from vMAJOR.MINOR.PATCH" {
    run "$SCRIPTS_DIR/major-tag.sh" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$output" = "v1" ]
}

@test "extracts vMAJOR from a two-digit major" {
    run "$SCRIPTS_DIR/major-tag.sh" "v12.3.4"
    [ "$status" -eq 0 ]
    [ "$output" = "v12" ]
}

@test "preserves absent v prefix" {
    run "$SCRIPTS_DIR/major-tag.sh" "3.4.5"
    [ "$status" -eq 0 ]
    [ "$output" = "3" ]
}

@test "handles pre-release suffix" {
    run "$SCRIPTS_DIR/major-tag.sh" "v2.0.0-rc.1"
    [ "$status" -eq 0 ]
    [ "$output" = "v2" ]
}

@test "fails on empty tag" {
    run "$SCRIPTS_DIR/major-tag.sh" ""
    [ "$status" -ne 0 ]
}

@test "fails on non-semver tag" {
    run "$SCRIPTS_DIR/major-tag.sh" "latest"
    [ "$status" -ne 0 ]
}

@test "fails on tag with only major" {
    run "$SCRIPTS_DIR/major-tag.sh" "v1"
    [ "$status" -ne 0 ]
}
