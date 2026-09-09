#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace

    cd "$TMP_WORKSPACE"
    git init --quiet --initial-branch=main
    git config user.email "test@example.com"
    git config user.name "test"

    git commit --quiet --allow-empty -m "first"
    git tag v1.0.0
    git commit --quiet --allow-empty -m "second"
    git tag v1.1.0
    git commit --quiet --allow-empty -m "third"
    git tag v2.0.0
}

teardown() {
    teardown_tmp_workspace
}

@test "prints the closest version tag before the given tag" {
    run "$SCRIPTS_DIR/previous-tag.sh" v2.0.0
    [ "$status" -eq 0 ]
    [ "$output" = "v1.1.0" ]
}

@test "skips intermediate non-version tags" {
    git tag latest v1.1.0
    run "$SCRIPTS_DIR/previous-tag.sh" v2.0.0
    [ "$status" -eq 0 ]
    [ "$output" = "v1.1.0" ]
}

@test "supports tags without the v prefix" {
    git commit --quiet --allow-empty -m "fourth"
    git tag 3.0.0
    git commit --quiet --allow-empty -m "fifth"
    git tag 3.1.0
    run "$SCRIPTS_DIR/previous-tag.sh" 3.1.0
    [ "$status" -eq 0 ]
    [ "$output" = "3.0.0" ]
}

@test "prints nothing when no previous version tag exists" {
    run "$SCRIPTS_DIR/previous-tag.sh" v1.0.0
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "fails when the tag argument is missing" {
    run "$SCRIPTS_DIR/previous-tag.sh"
    [ "$status" -eq 2 ]
}

@test "fails when the tag does not exist" {
    run "$SCRIPTS_DIR/previous-tag.sh" v9.9.9
    [ "$status" -eq 2 ]
    [[ "$output" == *"v9.9.9"* ]]
}
