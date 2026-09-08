#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace

    ORIGIN="$TMP_WORKSPACE/origin.git"
    CLONE="$TMP_WORKSPACE/clone"

    git init --quiet --bare --initial-branch=main "$ORIGIN"
    git clone --quiet "$ORIGIN" "$CLONE"

    cd "$CLONE"
    git config user.email "test@example.com"
    git config user.name "test"

    echo "1.0.0" > VERSION
    echo "## [1.0.0]" > CHANGELOG.md
    git add VERSION CHANGELOG.md
    git commit --quiet -m "initial"
    git tag v1.0.0
    git push --quiet origin main v1.0.0
}

teardown() {
    teardown_tmp_workspace
}

# Reproduces what `actions/checkout` does for a tag-triggered workflow: a fresh
# clone holding the tag only, checked out as a detached HEAD.
detached_tag_checkout() {
    git clone --quiet --no-checkout "$ORIGIN" "$TMP_WORKSPACE/detached"
    cd "$TMP_WORKSPACE/detached"
    git checkout --quiet --detach v1.0.0
    git config user.email "test@example.com"
    git config user.name "test"
    git update-ref -d refs/remotes/origin/main
}

# Adds a commit to origin/main that the v1.0.0 tag does not contain.
advance_main() {
    echo "1.0.1" > VERSION
    echo "## [1.0.1]" > CHANGELOG.md
    git commit --quiet -am "later work"
    git push --quiet origin main
}

@test "attaches a detached HEAD to the branch" {
    detached_tag_checkout

    run "$SCRIPTS_DIR/checkout-commit-branch.sh" main
    [ "$status" -eq 0 ]
    [ "$(git rev-parse --abbrev-ref HEAD)" = "main" ]
}

@test "is a no-op when already on the branch" {
    run "$SCRIPTS_DIR/checkout-commit-branch.sh" main
    [ "$status" -eq 0 ]
    [ "$(git rev-parse --abbrev-ref HEAD)" = "main" ]
}

@test "preserves untracked files produced earlier in the workflow" {
    detached_tag_checkout
    echo "artifact" > build.out

    run "$SCRIPTS_DIR/checkout-commit-branch.sh" main
    [ "$status" -eq 0 ]
    [ "$(cat build.out)" = "artifact" ]
}

@test "moves onto the branch tip when the tag lags behind it" {
    advance_main

    detached_tag_checkout

    run "$SCRIPTS_DIR/checkout-commit-branch.sh" main
    [ "$status" -eq 0 ]
    [ "$(cat VERSION)" = "1.0.1" ]
}

# The failure this script exists to prevent: once the release steps have
# rewritten CHANGELOG.md, git can no longer leave the tag commit for a branch
# tip that carries a different CHANGELOG.md. Running before those steps is what
# keeps the switch legal.
@test "reports the conflict when local changes block the switch" {
    advance_main

    detached_tag_checkout
    echo "## [1.0.1]" >> CHANGELOG.md

    run "$SCRIPTS_DIR/checkout-commit-branch.sh" main
    [ "$status" -eq 1 ]
    [[ "$output" == *"cannot switch to branch 'main'"* ]]
}

@test "fails on missing branch" {
    run "$SCRIPTS_DIR/checkout-commit-branch.sh"
    [ "$status" -eq 2 ]
}

@test "fails when the branch does not exist on origin" {
    detached_tag_checkout

    run "$SCRIPTS_DIR/checkout-commit-branch.sh" nonexistent
    [ "$status" -ne 0 ]
    [[ "$output" == *"cannot fetch branch 'nonexistent'"* ]]
}
