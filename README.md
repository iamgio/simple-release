# simple-release

Opinionated but customizable composite GitHub Action for cutting releases. It
bundles the pieces you usually copy-paste into every release workflow, exposes
each one as an opt-in input, and stays out of the way when you don't want a
given step.

**Linux runners only.** All shell logic is bash and targets `ubuntu-latest`.

## What it does

Each step is opt-in via its input. Nothing runs unless you ask for it.

- **Version-file bump** — writes the tag (leading `v` stripped by default) into
  a file like `version.txt` so downstream build tooling can read it.
- **Changelog update** — turns an `[Unreleased]` section in a
  [keep-a-changelog](https://keepachangelog.com/) file into a dated release
  section, using
  [`thomaseizinger/keep-a-changelog-new-release`](https://github.com/thomaseizinger/keep-a-changelog-new-release).
- **Release notes extraction** — extracts the notes for the current tag from
  the changelog via
  [`ffurrer2/extract-release-notes`](https://github.com/ffurrer2/extract-release-notes).
- **Sponsors block** — appends the content of a file (e.g. `SPONSORS.md`) to
  the release body.
- **Commit-back** — commits the bumped `version-file` and `changelog-file` back
  to a branch using
  [`stefanzweifel/git-auto-commit-action`](https://github.com/stefanzweifel/git-auto-commit-action).
- **Devbuild prerelease** — force-moves a rolling tag (e.g. `latest`) to the
  current commit and publishes a prerelease with attached artifacts, ideal for
  "nightly" or "development build" downloads.
- **Tagged release** — publishes the actual release with a composed body and
  attached artifacts via
  [`softprops/action-gh-release`](https://github.com/softprops/action-gh-release).
- **Major-version tag alias** — for reusable GitHub Actions: extracts the
  major from the tag (`v2.3.4` → `v2`) and force-pushes it, so consumers can
  pin `@v2` and receive minor and patch updates automatically.

## Quick start

### Cut a release when a tag is pushed

```yaml
name: Release
on:
  push:
    tags: ['v*']

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: iamgio/simple-release@v0
        with:
          version-file: version.txt
          changelog-file: CHANGELOG.md
          sponsors-file: SPONSORS.md
          commit: 'true'
          release-files: |
            build/dist/*.zip
            build/dist/*.tar.gz
```

### Also publish a rolling devbuild on every `main` push

```yaml
name: Devbuild
on:
  push:
    branches: [main]

permissions:
  contents: write

jobs:
  devbuild:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: iamgio/simple-release@v0
        with:
          devbuild-tag: latest
          devbuild-files: build/dist/*.zip
```

### Release a reusable GitHub Action (major-tag alias)

```yaml
name: Release
on:
  push:
    tags: ['v*.*.*']

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: iamgio/simple-release@v0
        with:
          release: 'true'
          major-tag: 'true'
```

`v2.3.4` will publish a release and force-move the `v2` tag to the same commit.
Consumers pinning `@v2` will get the update automatically.

## Inputs

### Core

| Input             | Default              | Description                                                        |
|-------------------|----------------------|--------------------------------------------------------------------|
| `tag`             | `github.ref_name`    | Tag for the release.                                               |
| `token`           | `github.token`       | Token used to create the releases.                                 |
| `committer-token` | falls back to `token`| Token for pushing commits and moving tags. Use a PAT if needed.    |

### Version file (opt-in via `version-file`)

| Input           | Default | Description                                                                          |
|-----------------|---------|--------------------------------------------------------------------------------------|
| `version-file`  | `''`    | Path to a file to overwrite with the version. Leave empty to skip.                   |
| `keep-v-prefix` | `false` | When `true`, writes the tag verbatim. Otherwise strips the leading `v`.              |

### Changelog (opt-in via `changelog-file`)

| Input                   | Default                                     | Description                                                                                                                                     |
|-------------------------|---------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| `changelog-file`        | `''`                                        | Path to a keep-a-changelog file. Leave empty to skip.                                                                                           |
| `update-changelog`      | `true`                                      | Turn `[Unreleased]` into a dated release section. Set to `false` when calling the action twice in the same job and the update already happened. |
| `extract-release-notes` | auto (`true` when changelog set and releasing) | Extract release notes for the tag from the changelog. Explicit `true`/`false` overrides.                                                    |

### Sponsors

| Input           | Default | Description                                                                          |
|-----------------|---------|--------------------------------------------------------------------------------------|
| `sponsors-file` | `''`    | If set and existing, appended after release notes in the release body.               |

### Release-notes spacers

| Input            | Default | Description                                                                                                                                                                                                                                                 |
|------------------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `insert-spacers` | `false` | When `true`, inserts a `&nbsp;` spacer line before every `###` and `####` heading in the extracted release notes (except the very first heading, so the notes never start with a stray spacer). Only touches the composed body; the pushed changelog file is never rewritten. Skipped when `release-body` is passed literally. |

### Commit back (opt-in via `commit`)

| Input               | Default                                              | Description                                                                                    |
|---------------------|------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `commit`            | `false`                                              | Commit the modified `version-file` and `changelog-file` back to a branch.                      |
| `commit-message`    | `chore: release {tag}`                               | `{tag}` is substituted with the tag.                                                           |
| `commit-user-name`  | `github-actions`                                     |                                                                                                |
| `commit-user-email` | `github-actions[bot]@users.noreply.github.com`       |                                                                                                |
| `commit-branch`     | `main`                                               | Branch to push the commit to.                                                                  |

### Devbuild (opt-in via `devbuild-tag`)

| Input            | Default             | Description                                                                                    |
|------------------|---------------------|------------------------------------------------------------------------------------------------|
| `devbuild-tag`   | `''`                | Name of the rolling tag to force-move to this commit (e.g. `latest`). Leave empty to skip.     |
| `devbuild-name`  | `Development build` | Display name for the prerelease.                                                               |
| `devbuild-files` | `''`                | Newline- or comma-separated glob patterns of files to attach.                                  |

### Tagged release

| Input                | Default                       | Description                                                                                    |
|----------------------|-------------------------------|------------------------------------------------------------------------------------------------|
| `release`            | `auto`                        | `auto` = create when ref is a tag. Use `true`/`false` to force behavior.                       |
| `release-name`       | `''` (tag)                    | Release display name.                                                                          |
| `release-body`       | composed                      | Literal Markdown body. If empty, composed from release notes and sponsors.                     |
| `release-files`      | `''`                          | Newline- or comma-separated glob patterns of files to attach.                                  |
| `release-draft`      | `false`                       |                                                                                                |
| `release-prerelease` | `false`                       |                                                                                                |

### Major-version tag alias

| Input       | Default | Description                                                                                                         |
|-------------|---------|---------------------------------------------------------------------------------------------------------------------|
| `major-tag` | `false` | When `true`, extracts the major from the tag (e.g. `v2` from `v2.3.4`) and force-pushes it to the current commit.   |

## Outputs

| Output          | Description                                                       |
|-----------------|-------------------------------------------------------------------|
| `version`       | The computed version (tag with leading `v` optionally stripped).  |
| `is-tag`        | Whether the workflow ref is a tag.                                |
| `release-notes` | Extracted release notes for the tag, if the changelog step ran.   |
| `release-url`   | URL of the created release, if any.                               |
| `devbuild-url`  | URL of the created devbuild release, if any.                      |

## Permissions

The calling workflow needs `contents: write` for any step that pushes tags,
commits, or creates releases. When commit-back or devbuild-tag pushing must
target a protected branch, pass a PAT as `committer-token`.

## Versioning

This action follows semver via `v{major}.{minor}.{patch}` tags. A matching
`v{major}` alias is force-moved on every release, so pinning `@v0` gives you
the latest 0.x. The pattern is dogfooded in
[`.github/workflows/release.yml`](.github/workflows/release.yml).

## Development

```bash
# install bats
brew install bats-core        # macOS
sudo apt-get install -y bats  # Debian/Ubuntu

# run tests
bats tests/
```

CI runs the same bats tests plus a light `action.yml` sanity check on every
push and PR.
