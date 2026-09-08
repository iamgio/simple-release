#!/usr/bin/env bash
# Sets the `version` field of a package.json-style JSON manifest.
#
# Usage: bump-package-json.sh <manifest-file> <tag>
#
# The leading `v` is always stripped, unlike `bump-version.sh`: npm requires the
# version field to be plain semver, so a `v`-prefixed value would be invalid.
#
# Only the version is rewritten. A manifest formatted the usual way keeps every
# other byte, so the resulting commit touches a single line. A manifest whose
# version cannot be located that way (unusual formatting, or no version field at
# all) is re-serialized instead, which may reformat it.

set -euo pipefail

file="${1:-}"
tag="${2:-}"

if [ -z "$file" ]; then
    echo "bump-package-json.sh: missing manifest path" >&2
    exit 2
fi

if [ -z "$tag" ]; then
    echo "bump-package-json.sh: missing tag" >&2
    exit 2
fi

if [ ! -f "$file" ]; then
    echo "bump-package-json.sh: manifest '$file' does not exist" >&2
    exit 2
fi

if ! command -v node >/dev/null 2>&1; then
    echo "bump-package-json.sh: node is required to edit '$file'" >&2
    exit 2
fi

node -e '
const fs = require("fs");
const [file, tag] = process.argv.slice(1);
const version = tag.replace(/^v/, "");
const source = fs.readFileSync(file, "utf8");

try {
    JSON.parse(source);
} catch (error) {
    console.error(`bump-package-json.sh: ${file} is not valid JSON: ${error.message}`);
    process.exit(2);
}

// Indentation of the first nested key, reused so the manifest keeps its shape.
const indent = (source.match(/\n([ \t]+)"/) || [])[1] || "  ";

// Anchoring to that indentation keeps the match at the top level, so a nested
// "version" (in an engines block, say) is never mistaken for the manifest own.
const topLevelVersion = new RegExp(`^${indent}"version"(\\s*:\\s*)"[^"]*"`, "m");

let updated;
if (topLevelVersion.test(source)) {
    updated = source.replace(topLevelVersion, `${indent}"version"$1${JSON.stringify(version)}`);
} else {
    const manifest = JSON.parse(source);
    manifest.version = version;
    const trailingNewline = source.endsWith("\n") ? "\n" : "";
    updated = JSON.stringify(manifest, null, indent) + trailingNewline;
}

fs.writeFileSync(file, updated);
' "$file" "$tag"
