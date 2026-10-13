#!/bin/bash
# Deploy local do KeyBridge: compila, instala o app e o agente (mini-bundle
# próprio com ícone e LSUIElement — sem Dock, sem bounce), sem deixar
# processo órfão.
set -euo pipefail
cd "$(dirname "$0")/.."

./Scripts/build.sh

AGENT_DIR="$HOME/Library/Application Support/KeyBridge"
AGENT_APP="$AGENT_DIR/KeyBridgeAgent.app"
AGENT_BIN="$AGENT_APP/Contents/MacOS/KeyBridgeAgent"
PLIST="$HOME/Library/LaunchAgents/local.keybridge.agent.plist"
SVC="gui/$(id -u)/local.keybridge.agent"

# 1) Para o gerenciamento do launchd (evita respawn durante a cópia)
launchctl bootout "$SVC" 2>/dev/null || true

# 2) Encerra qualquer processo do app/agente antigo (GUI incluída)
pkill -f "/Applications/KeyBridge.app/Contents/MacOS/KeyBridge" 2>/dev/null || true
pkill -f "KeyBridgeAgent" 2>/dev/null || true
sleep 1

# 3) Instala o app (GUI)
rm -rf /Applications/KeyBridge.app
cp -R build/KeyBridge.app /Applications/
test -x /Applications/KeyBridge.app/Contents/MacOS/KeyBridge

# 4) Monta o mini-bundle do agente (identidade separada, ícone, LSUIElement)
rm -rf "$AGENT_APP" "$AGENT_DIR/KeyBridgeAgent"   # inclui o formato antigo (binário puro)
mkdir -p "$AGENT_APP/Contents/MacOS" "$AGENT_APP/Contents/Resources"
cp "/Applications/KeyBridge.app/Contents/MacOS/KeyBridge" "$AGENT_BIN"
cp "/Applications/KeyBridge.app/Contents/Resources/KeyBridgeIcon.icns" "$AGENT_APP/Contents/Resources/" 2>/dev/null || true
cat > "$AGENT_APP/Contents/Info.plist" <<APPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key><string>KeyBridge Agent</string>
  <key>CFBundleExecutable</key><string>KeyBridgeAgent</string>
  <key>CFBundleIdentifier</key><string>local.keybridge.agent</string>
  <key>CFBundleName</key><string>KeyBridgeAgent</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleIconFile</key><string>KeyBridgeIcon</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
APPLIST

# 5) (Re)escreve o LaunchAgent apontando para o binário do agente
cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>local.keybridge.agent</string>
  <key>ProgramArguments</key>
  <array>
    <string>$AGENT_BIN</string>
    <string>--agent</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/keybridge.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/keybridge.log</string>
</dict>
</plist>
PLIST

# 6) Reativa o agente
launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null || true

sleep 2
if pgrep -f "$AGENT_BIN --agent" >/dev/null; then
  echo "✅ Deploy OK — agente rodando de $AGENT_APP (ícone do app, sem Dock, sem bounce)."
  echo "⚠️  Binário mudou: readicione as permissões (Device Control + Input Monitoring)"
  echo "    para 'KeyBridgeAgent'. GUI: abre pelo Spotlight/Launchpad normalmente."
else
  echo "⚠️  Agente não subiu — verifique ~/Library/Logs/keybridge.log"
  exit 1
fi
