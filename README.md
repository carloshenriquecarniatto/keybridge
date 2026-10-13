# KeyBridge

**KeyBridge** is a small native macOS app for mapping special keyboard keys, macro keys, and vendor-specific G-keys to simple macOS actions.

It is intended as a lightweight, user-friendly alternative for people who do not need the full complexity of Karabiner-Elements just to map a few macro keys.

KeyBridge is vendor-neutral. It can be used with Logitech G HUB, Razer Synapse, Corsair iCUE, VIA/QMK, OpenLogi, or any keyboard software/firmware that can send uncommon keys such as `F13`–`F24`.

> Status: early prototype / MVP.

## Why

Many keyboards have extra macro keys, but macOS does not always expose a simple way to map them to native actions such as:

- Globe / fn behavior
- Emoji picker
- input source switching
- Mission Control / window shortcuts
- custom shortcuts
- app-specific actions

Karabiner-Elements can solve many of these cases, but it is powerful and complex. KeyBridge focuses on a simpler workflow: capture a key, choose an action, done.

## How it works

1. In your keyboard software, map each macro key to a rarely used key, for example:

   ```text
   G1 → F13
   G2 → F14
   G3 → F15
   G4 → F16
   G5 → F17
   ```

2. Open KeyBridge.
3. Click **Capture next key** and press the macro key.
4. Choose the action you want.
5. Install the helper agent at login.

KeyBridge runs a small macOS event-tap helper that only handles the keycodes you configure.

## Current actions

The current prototype supports:

- **Globe/fn**
  - Tap: opens Emoji & Symbols
  - Hold: adds the macOS `fn` / Globe flag to the next key
- **Emoji**
- **Input Source switch**
- **Disabled**

More actions are planned.

## Supported keyboards

KeyBridge is not limited to Logitech.

It should work with any keyboard or vendor app that can emit regular macOS keyboard events, including keys such as `F13`–`F24` or other unused keycodes.

Examples:

- Logitech G HUB / G-keys
- Razer Synapse macro keys
- Corsair iCUE macro keys
- VIA / QMK keyboards
- OpenLogi experiments
- Any keyboard firmware or app that can send a unique keycode

## macOS permissions

KeyBridge needs macOS privacy permissions because it observes and transforms keyboard events.

On recent macOS versions, enable KeyBridge in:

```text
System Settings → Privacy & Security → Device Control and Data Access
System Settings → Privacy & Security → Input Monitoring
```

On older macOS versions, the first permission may appear as:

```text
System Settings → Privacy & Security → Accessibility
```

On macOS 27, Apple appears to label the former Accessibility permission as:

```text
Allow assistive applications to control the computer
```

or inside:

```text
Device Control and Data Access
```

If KeyBridge was rebuilt locally, remove and re-add it in these permission lists. Ad-hoc signed local apps can lose their TCC permission identity after recompilation.

## Build from source

Requirements:

- macOS
- Xcode Command Line Tools
- Swift compiler

Build:

```bash
./Scripts/build.sh
```

Run:

```bash
open build/KeyBridge.app
```

Or build and run:

```bash
./Scripts/run.sh
```

## Local installation

After building:

```bash
cp -R build/KeyBridge.app /Applications/
open /Applications/KeyBridge.app
```

Then grant the required permissions in System Settings.

## Distribution and code signing

For local development, KeyBridge is currently signed ad-hoc:

```bash
codesign --sign -
```

This is enough for local testing, but it is not ideal for public distribution.

For a good user experience, public macOS builds should be:

1. signed with an Apple **Developer ID Application** certificate;
2. notarized with Apple;
3. stapled after notarization;
4. distributed as a `.dmg`, `.zip`, or Homebrew Cask artifact.

Without Developer ID signing and notarization, users may see Gatekeeper warnings such as:

```text
“KeyBridge” cannot be opened because the developer cannot be verified.
```

or they may need to right-click → Open, or manually remove quarantine attributes.

## Homebrew distribution

There are two common Homebrew approaches:

### Homebrew Formula

A formula builds from source on the user's machine.

This usually does **not** require Developer ID signing because the user is building locally. However, for a macOS app that needs Accessibility/Input Monitoring permissions, unsigned or ad-hoc builds can be annoying because macOS TCC permissions may reset when the binary changes.

### Homebrew Cask

A cask installs a prebuilt `.app`, `.zip`, or `.dmg`.

For a smooth Cask experience, the app should be Developer ID signed and notarized. Homebrew can technically distribute unsigned apps, but users may hit Gatekeeper friction and the cask may need caveats explaining how to open it.

Recommended path for KeyBridge:

1. Early stage: GitHub Releases with unsigned/ad-hoc builds and clear caveats.
2. Later: Developer ID signing + notarization.
3. Then: Homebrew Cask.

## Configuration

KeyBridge stores mappings in:

```text
~/.config/keybridge/mappings.json
```

Logs are stored in:

```text
~/Library/Logs/keybridge.log
```

The login helper is installed as:

```text
~/Library/LaunchAgents/local.keybridge.agent.plist
```

## Project goals

- Simple visual setup
- Vendor-neutral macro-key mapping
- Native macOS design
- Easy onboarding for non-technical users
- Minimal background helper
- Reusable configuration
- Friendly alternative for common Karabiner use cases

## Relationship to OpenLogi

KeyBridge can be used as a standalone app, but it may also serve as a prototype/reference for future Logitech keyboard support in OpenLogi.

The long-term idea is to make Logitech G-key workflows on macOS easier, more native, and less dependent on Logitech G HUB.

## License

MIT

## Releases

KeyBridge uses [semantic-release](https://semantic-release.gitbook.io/) with Conventional Commits.

When commits are pushed to `main`, GitHub Actions will:

1. build `KeyBridge.app`;
2. package it as `build/KeyBridge.zip`;
3. analyze Conventional Commit messages;
4. create a semantic version tag such as `v0.2.0`;
5. generate GitHub release notes;
6. upload the app zip to the GitHub Release;
7. update `CHANGELOG.md`.

### Commit examples

```text
fix: avoid beep when consuming mapped macro key
feat: add custom shortcut action
chore: update icon assets
docs: explain G HUB setup
```

Release impact:

- `fix:` → patch release
- `feat:` → minor release
- `feat!:` or `BREAKING CHANGE:` → major release
- `docs:`, `chore:`, `refactor:` → no release by default

### First release

The first automated release will happen after a release-triggering commit is pushed to `main`, for example:

```bash
git commit -m "feat: add initial KeyBridge MVP"
```

### Note about release binaries

Current GitHub Release artifacts are ad-hoc signed and not notarized. They are useful for early testing, but users may still see Gatekeeper warnings. A smoother public distribution will require Developer ID signing and Apple notarization.
