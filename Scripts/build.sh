#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="KeyBridge"
BUNDLE_ID="local.keybridge.app"
BUILD_DIR="$ROOT/build"
APP="$BUILD_DIR/$APP_NAME.app"
SRC="$ROOT/Sources/KeyBridge.swift"
ICONSET="$ROOT/Assets/KeyBridge.iconset"
ICON="$APP/Contents/Resources/KeyBridgeIcon.icns"
SIGN_IDENTITY="${KEYBRIDGE_SIGN_IDENTITY:--}"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

swiftc -O "$SRC" -o "$APP/Contents/MacOS/$APP_NAME"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>CFBundleIconFile</key><string>KeyBridgeIcon</string>
</dict>
</plist>
PLIST

if [[ -d "$ICONSET" ]]; then
  iconutil -c icns "$ICONSET" -o "$ICON"
elif [[ -f "$ROOT/Assets/KeyBridgeIcon.icns" ]]; then
  cp "$ROOT/Assets/KeyBridgeIcon.icns" "$ICON"
fi

codesign --force --deep --sign "$SIGN_IDENTITY" --identifier "$BUNDLE_ID" "$APP"

echo "Built: $APP"
if [[ "$SIGN_IDENTITY" == "-" ]]; then
  echo "Signed ad-hoc. For distribution, use Developer ID signing + notarization."
fi
