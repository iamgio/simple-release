# Changelog

## [Unreleased]

## [1.4.0] - 2026-11-10

### Added

-   The `push-tag` option (default: `false`) tags the release commit and pushes the commit and the tag together, so you can start a release from a manually triggered workflow instead of pushing a tag. The tag then carries the bumped version and changelog, the leading `v` of the version is optional, and nothing is pushed when the tag already exists or the version is already released.

### Changed

-   `commit` now pushes the release commit with `committer-token` when it's set, like the devbuild and major-version tags. Without it, pushes keep using the credentials persisted by `actions/checkout`, as before.

### Fixed

-   `committer-token` now takes effect when `actions/checkout` persisted different credentials. Previously, git kept authenticating with the checkout token, so devbuild and major-version tag pushes couldn't trigger other workflows or bypass branch protection with a PAT.

## [1.3.1] - 2026-09-09

### Fixed

-   `replace-version-in-files` now resolves the previous release by version order across all `v*` tags, instead of the closest tag reachable in history, which misidentified the previous version when tags didn't sit on the release branch.

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

[Unreleased]: https://github.com/iamgio/simple-release/compare/v1.4.0...HEAD

[1.4.0]: https://github.com/iamgio/simple-release/compare/v1.3.1...v1.4.0

[1.3.1]: https://github.com/iamgio/simple-release/compare/v1.3.0...v1.3.1

[1.3.0]: https://github.com/iamgio/simple-release/compare/v1.2.0...v1.3.0

[1.2.0]: https://github.com/iamgio/simple-release/compare/v1.1.0...v1.2.0

[1.1.0]: https://github.com/iamgio/simple-release/compare/v1.0.2...v1.1.0

[1.0.2]: https://github.com/iamgio/simple-release/compare/v1.0.1...v1.0.2

[1.0.1]: https://github.com/iamgio/simple-release/compare/v1.0.0...v1.0.1

[1.0.0]: https://github.com/iamgio/simple-release/compare/e4cbcb8121a21d237f0f5153ed73d89fc146cf9d...v1.0.0
