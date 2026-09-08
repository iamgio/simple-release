#!/usr/bin/env bats

load 'test_helper'

setup() {
    setup_scripts_dir
    setup_tmp_workspace
    MANIFEST="$TMP_WORKSPACE/package.json"
}

teardown() {
    teardown_tmp_workspace
}

# Writes a conventional two-space manifest to $MANIFEST.
write_manifest() {
    cat > "$MANIFEST" << 'JSON'
{
    "name": "example",
    "version": "0.1.0",
    "scripts": {
        "build": "tsc"
    }
}
JSON
}

@test "strips leading v and sets the version" {
    write_manifest
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$(node -p "require('$MANIFEST').version")" = "1.2.3" ]
}

@test "leaves a tag without v prefix untouched" {
    write_manifest
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "2.0.0"
    [ "$status" -eq 0 ]
    [ "$(node -p "require('$MANIFEST').version")" = "2.0.0" ]
}

@test "handles semver with pre-release suffix" {
    write_manifest
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.0.0-rc.1"
    [ "$status" -eq 0 ]
    [ "$(node -p "require('$MANIFEST').version")" = "1.0.0-rc.1" ]
}

@test "changes only the version line" {
    write_manifest
    cp "$MANIFEST" "$TMP_WORKSPACE/before.json"

    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.2.3"
    [ "$status" -eq 0 ]

    run diff "$TMP_WORKSPACE/before.json" "$MANIFEST"
    # One changed line: a single `<` and a single `>` in the diff output.
    [ "$(printf '%s\n' "$output" | grep -c '^<')" -eq 1 ]
    [ "$(printf '%s\n' "$output" | grep -c '^>')" -eq 1 ]
    printf '%s\n' "$output" | grep -q '"version": "1.2.3"'
}

@test "preserves other fields and key order" {
    write_manifest
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$(node -p "Object.keys(require('$MANIFEST')).join(',')")" = "name,version,scripts" ]
    [ "$(node -p "require('$MANIFEST').scripts.build")" = "tsc" ]
}

@test "ignores a nested version field" {
    cat > "$MANIFEST" << 'JSON'
{
    "engines": {
        "version": "18"
    },
    "version": "0.1.0"
}
JSON
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$(node -p "require('$MANIFEST').engines.version")" = "18" ]
    [ "$(node -p "require('$MANIFEST').version")" = "1.2.3" ]
}

@test "adds a version field when the manifest has none" {
    printf '{\n  "name": "example"\n}\n' > "$MANIFEST"
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.2.3"
    [ "$status" -eq 0 ]
    [ "$(node -p "require('$MANIFEST').version")" = "1.2.3" ]
    [ "$(node -p "require('$MANIFEST').name")" = "example" ]
}

@test "preserves tab indentation" {
    printf '{\n\t"name": "example",\n\t"version": "0.1.0"\n}\n' > "$MANIFEST"
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.2.3"
    [ "$status" -eq 0 ]
    grep -q "$(printf '\t"version": "1.2.3"')" "$MANIFEST"
}

@test "fails when manifest path is empty" {
    run "$SCRIPTS_DIR/bump-package-json.sh" "" "v1.0.0"
    [ "$status" -ne 0 ]
}

@test "fails when tag is empty" {
    write_manifest
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" ""
    [ "$status" -ne 0 ]
}

@test "fails when the manifest does not exist" {
    run "$SCRIPTS_DIR/bump-package-json.sh" "$TMP_WORKSPACE/missing.json" "v1.0.0"
    [ "$status" -ne 0 ]
}

@test "fails when the manifest is not valid JSON" {
    printf 'not json' > "$MANIFEST"
    run "$SCRIPTS_DIR/bump-package-json.sh" "$MANIFEST" "v1.0.0"
    [ "$status" -ne 0 ]
}
