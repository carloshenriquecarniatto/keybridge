# Contributing to KeyBridge

Thanks for your interest in contributing to KeyBridge.

## Commit convention

This project uses Conventional Commits and semantic-release.

Use commit messages like:

```text
feat: add custom shortcut action
fix: handle repeated macro key events
chore: update build script
docs: improve installation guide
refactor: split agent state
```

## Release rules

Releases are created automatically from commits pushed to `main`.

Common release behavior:

| Commit type | Result |
| --- | --- |
| `fix:` | Patch release |
| `feat:` | Minor release |
| `feat!:` or `BREAKING CHANGE:` | Major release |
| `docs:`, `chore:`, `refactor:`, `test:` | No release by default |

Examples:

```text
fix: consume macro key up events correctly
```

creates a patch release.

```text
feat: add import and export for mapping profiles
```

creates a minor release.

```text
feat!: change mapping configuration format

BREAKING CHANGE: mappings.json now uses profile-based configuration.
```

creates a major release.

## Local build

```bash
./Scripts/build.sh
open build/KeyBridge.app
```

## Release dry run

```bash
npm ci
npm run release:dry
```

The real release runs on GitHub Actions when changes are pushed to `main`.
