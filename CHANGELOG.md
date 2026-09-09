# Changelog

## [Unreleased]

## [1.3.0] - 2026-09-09

### Added

-   The `replace-version-in-files` option replaces every occurrence of the previous release version with the new one in the given files (e.g. installation snippets in `README.md`).

## [1.2.0] - 2026-09-08

### Added

-   The `bump-package-json` option (default: `false`) sets the `version` field of the root `package.json` to the release version.

### Fixed

-   `commit` no longer aborts on tag-triggered workflows. The `commit-branch` is now checked out before the release files are rewritten, instead of afterwards, when the pending changes made git refuse to leave the detached HEAD.

## [1.1.0] - 2026-08-09

### Added

-   The `auto-detect-prerelease` option marks a release as a prerelease when the tag's semver pre-release segment (e.g. `alpha`, `beta`, `rc`) matches the configurable `prerelease-keywords`.

## [1.0.2] - 2026-07-27

### Fixed

-   Devbuild release body no longer accumulates over time

## [1.0.1] - 2026-07-26

### Added

#### Marketplace readiness

The action is now ready for the GitHub Marketplace.

## [1.0.0] - 2026-07-26

Initial stable release. See the [README](README.adoc) for the full feature list.

[Unreleased]: https://github.com/iamgio/simple-release/compare/v1.3.0...HEAD

[1.3.0]: https://github.com/iamgio/simple-release/compare/v1.2.0...v1.3.0

[1.2.0]: https://github.com/iamgio/simple-release/compare/v1.1.0...v1.2.0

[1.1.0]: https://github.com/iamgio/simple-release/compare/v1.0.2...v1.1.0

[1.0.2]: https://github.com/iamgio/simple-release/compare/v1.0.1...v1.0.2

[1.0.1]: https://github.com/iamgio/simple-release/compare/v1.0.0...v1.0.1

[1.0.0]: https://github.com/iamgio/simple-release/compare/e4cbcb8121a21d237f0f5153ed73d89fc146cf9d...v1.0.0
