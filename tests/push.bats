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
    git add VERSION
    git commit --quiet -m "initial"
    git push --quiet origin main
}

teardown() {
    teardown_tmp_workspace
}

# Mirrors the release commit and annotated tag created by git-auto-commit-action.
release_commit() {
    echo "$1" > VERSION
    git commit --quiet -am "chore: release v$1"
    git tag -a "v$1" -m "v$1"
}

@test "pushes the branch and the tag together" {
    release_commit 1.1.0

    run "$SCRIPTS_DIR/push.sh" https://github.com "$ORIGIN" HEAD:refs/heads/main refs/tags/v1.1.0
    [ "$status" -eq 0 ]
    [ "$(git --git-dir="$ORIGIN" rev-parse main)" = "$(git rev-parse HEAD)" ]
    [ "$(git --git-dir="$ORIGIN" rev-parse 'v1.1.0^{commit}')" = "$(git rev-parse HEAD)" ]
}

@test "pushes nothing when the tag already exists on the remote" {
    git tag -a v1.1.0 -m "v1.1.0"
    git push --quiet origin v1.1.0
    git tag -d v1.1.0 > /dev/null
    before="$(git --git-dir="$ORIGIN" rev-parse main)"
    release_commit 1.1.0

    run "$SCRIPTS_DIR/push.sh" https://github.com "$ORIGIN" HEAD:refs/heads/main refs/tags/v1.1.0
    [ "$status" -ne 0 ]
    [ "$(git --git-dir="$ORIGIN" rev-parse main)" = "$before" ]
}

@test "force-moves a rolling tag" {
    git tag latest
    git push --quiet origin latest
    release_commit 1.1.0
    git tag -f latest > /dev/null

    run "$SCRIPTS_DIR/push.sh" https://github.com "$ORIGIN" +refs/tags/latest
    [ "$status" -eq 0 ]
    [ "$(git --git-dir="$ORIGIN" rev-parse latest)" = "$(git rev-parse HEAD)" ]
}

@test "pushes without an override server" {
    release_commit 1.1.0

    run "$SCRIPTS_DIR/push.sh" "" "$ORIGIN" HEAD:refs/heads/main
    [ "$status" -eq 0 ]
    [ "$(git --git-dir="$ORIGIN" rev-parse main)" = "$(git rev-parse HEAD)" ]
}

@test "fails on missing remote" {
    run "$SCRIPTS_DIR/push.sh" https://github.com "" HEAD:refs/heads/main
    [ "$status" -eq 2 ]
}

@test "fails on missing refspecs" {
    run "$SCRIPTS_DIR/push.sh" https://github.com "$ORIGIN"
    [ "$status" -eq 2 ]
}
