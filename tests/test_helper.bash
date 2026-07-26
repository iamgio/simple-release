#!/usr/bin/env bash
# Shared helpers for bats tests.

setup_scripts_dir() {
    SCRIPTS_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../scripts" && pwd)"
    export SCRIPTS_DIR
}

setup_tmp_workspace() {
    TMP_WORKSPACE="$(mktemp -d)"
    export TMP_WORKSPACE
}

teardown_tmp_workspace() {
    if [ -n "${TMP_WORKSPACE:-}" ] && [ -d "$TMP_WORKSPACE" ]; then
        rm -rf "$TMP_WORKSPACE"
    fi
}
