import SwiftUI
import AppKit

// MARK: - Shared model

let appName = "KeyBridge"
let bundleID = "local.keybridge.app"
let configDir = NSString(string: "~/.config/keybridge").expandingTildeInPath
let configPath = configDir + "/mappings.json"
let logPath = NSString(string: "~/Library/Logs/keybridge.log").expandingTildeInPath
let agentPlistPath = NSString(string: "~/Library/LaunchAgents/local.keybridge.agent.plist").expandingTildeInPath

enum KeyAction: String, Codable, CaseIterable, Identifiable {
    case globeFn
    case emoji
    case inputSource
    case disabled

    var id: String { rawValue }
    var title: String {
        switch self {
        case .globeFn: return "Globo/fn"
        case .emoji: return "Emoji"
        case .inputSource: return "Trocar idioma"
        case .disabled: return "Desligado"
        }
    }
    var subtitle: String {
        switch self {
        case .globeFn: return "Toque abre emoji; segurar adiciona fn"
        case .emoji: return "Abre Emoji & Símbolos"
        case .inputSource: return "Envia Ctrl+Espaço"
        case .disabled: return "Ignora esta tecla"
        }
    }
    var symbol: String {
        switch self {
        case .globeFn: return "globe"
        case .emoji: return "face.smiling"
        case .inputSource: return "character.cursor.ibeam"
        case .disabled: return "slash.circle"
        }
    }
}

struct KeyMapping: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var keyCode: Int64
    var action: KeyAction
    var enabled: Bool = true
}

struct KeyBridgeConfig: Codable {
    var mappings: [KeyMapping]
    var version: Int = 1

    static let defaults = KeyBridgeConfig(mappings: [
        KeyMapping(name: "G-Key 1", keyCode: 113, action: .globeFn),
    ])
}

func log(_ text: String) {
    let line = "[\(Date())] \(text)\n"
    if let fh = FileHandle(forWritingAtPath: logPath) {
        defer { try? fh.close() }
        fh.seekToEndOfFile()
        fh.write(line.data(using: .utf8)!)
    } else {
        try? line.write(toFile: logPath, atomically: true, encoding: .utf8)
    }
    print(text)
}

func ensureConfigDir() {
    try? FileManager.default.createDirectory(atPath: configDir, withIntermediateDirectories: true)
}

func loadConfig() -> KeyBridgeConfig {
    ensureConfigDir()
    guard let data = FileManager.default.contents(atPath: configPath),
          let cfg = try? JSONDecoder().decode(KeyBridgeConfig.self, from: data) else {
        saveConfig(.defaults)
        return .defaults
    }
    return cfg
}

func saveConfig(_ config: KeyBridgeConfig) {
    ensureConfigDir()
    let enc = JSONEncoder()
    enc.outputFormatting = [.prettyPrinted, .sortedKeys]
    if let data = try? enc.encode(config) {
        try? data.write(to: URL(fileURLWithPath: configPath), options: .atomic)
    }
}

func shell(_ executable: String, _ args: [String]) -> Int32 {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: executable)
    p.arguments = args
    do { try p.run() } catch { return 127 }
    p.waitUntilExit()
    return p.terminationStatus
}

func currentExecutablePath() -> String {
    Bundle.main.executableURL?.path ?? CommandLine.arguments[0]
}

// MARK: - Key posting helpers

var isPostingSynthetic = false

func postKey(_ virtualKey: CGKeyCode, flags: CGEventFlags = []) {
    isPostingSynthetic = true
    defer { isPostingSynthetic = false }
    guard let down = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: true),
          let up = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: false) else { return }
    down.flags = flags
    up.flags = flags
    down.post(tap: .cgAnnotatedSessionEventTap)
    usleep(30_000)
    up.post(tap: .cgAnnotatedSessionEventTap)
}

func postEmoji() { postKey(49, flags: [.maskControl, .maskCommand]) } // Ctrl+Cmd+Space
func postInputSource() { postKey(49, flags: [.maskControl]) } // Ctrl+Space

func typeName(_ t: CGEventType) -> String {
    switch t {
    case .keyDown: return "keyDown"
    case .keyUp: return "keyUp"
    case .flagsChanged: return "flagsChanged"
    default: return "raw\(t.rawValue)"
    }
}

// MARK: - Agent

final class AgentState {
    var mappingsByKeyCode: [Int64: KeyMapping] = [:]
    var heldGlobeKey: Int64? = nil
    var sawOtherKeyWhileHeld = false
    var lastConfigLoad = Date.distantPast

    func reloadIfNeeded(force: Bool = false) {
        let attrs = try? FileManager.default.attributesOfItem(atPath: configPath)
        let modified = attrs?[.modificationDate] as? Date ?? Date.distantPast
        if force || modified > lastConfigLoad {
            let cfg = loadConfig()
            mappingsByKeyCode = Dictionary(uniqueKeysWithValues: cfg.mappings.filter { $0.enabled }.map { ($0.keyCode, $0) })
            lastConfigLoad = Date()
            log("config carregada: \(mappingsByKeyCode.keys.sorted())")
        }
    }
}

let agentState = AgentState()

let agentCallback: CGEventTapCallBack = { _, type, event, _ in
    if isPostingSynthetic { return Unmanaged.passUnretained(event) }
    guard type == .keyDown || type == .keyUp else { return Unmanaged.passUnretained(event) }
    agentState.reloadIfNeeded()

    let keycode = event.getIntegerValueField(.keyboardEventKeycode)

    if let held = agentState.heldGlobeKey, keycode != held {
        agentState.sawOtherKeyWhileHeld = true
        event.flags = CGEventFlags(rawValue: event.flags.rawValue | CGEventFlags.maskSecondaryFn.rawValue)
        log("fn aplicado: key=\(keycode) por macro=\(held)")
        return Unmanaged.passUnretained(event)
    }

    guard let mapping = agentState.mappingsByKeyCode[keycode], mapping.action != .disabled else {
        return Unmanaged.passUnretained(event)
    }

    switch mapping.action {
    case .globeFn:
        if type == .keyDown {
            if agentState.heldGlobeKey == nil {
                agentState.heldGlobeKey = keycode
                agentState.sawOtherKeyWhileHeld = false
            }
            log("\(mapping.name) ↓ consumida como Globo/fn (keycode \(keycode))")
        } else {
            let wasTap = !agentState.sawOtherKeyWhileHeld
            agentState.heldGlobeKey = nil
            agentState.sawOtherKeyWhileHeld = false
            if wasTap {
                log("\(mapping.name) toque → emoji")
                DispatchQueue.global(qos: .userInitiated).async { postEmoji() }
            } else {
                log("\(mapping.name) solta após uso como fn")
            }
        }
        return nil
    case .emoji:
        if type == .keyUp {
            log("\(mapping.name) → emoji")
            DispatchQueue.global(qos: .userInitiated).async { postEmoji() }
        }
        return nil
    case .inputSource:
        if type == .keyUp {
            log("\(mapping.name) → trocar idioma")
            DispatchQueue.global(qos: .userInitiated).async { postInputSource() }
        }
        return nil
    case .disabled:
        return Unmanaged.passUnretained(event)
    }
}

func runAgent() -> Never {
    agentState.reloadIfNeeded(force: true)
    let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
    var notified = false
    while true {
        if let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask, callback: agentCallback, userInfo: nil) {
            let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
            log("KeyBridge Agent rodando")
            CFRunLoopRun()
        }
        log("Sem permissão para controlar/monitorar teclado; aguardando autorização")
        if !notified {
            notified = true
            _ = shell("/usr/bin/open", ["x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility"])
        }
        sleep(5)
    }
}

// MARK: - Capture one key

final class CaptureBox { var captured: Int64? = nil }

let captureCallback: CGEventTapCallBack = { _, type, event, userInfo in
    guard type == .keyDown else { return Unmanaged.passUnretained(event) }
    let box = Unmanaged<CaptureBox>.fromOpaque(userInfo!).takeUnretainedValue()
    box.captured = event.getIntegerValueField(.keyboardEventKeycode)
    CFRunLoopStop(CFRunLoopGetMain())
    return Unmanaged.passUnretained(event)
}

func captureOneKey(timeout: Int) -> Int32 {
    let box = CaptureBox()
    let ptr = UnsafeMutableRawPointer(Unmanaged.passRetained(box).toOpaque())
    defer { Unmanaged<CaptureBox>.fromOpaque(ptr).release() }
    let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
    guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .listenOnly, eventsOfInterest: mask, callback: captureCallback, userInfo: ptr) else {
        fputs("ERROR permission\n", stderr)
        return 2
    }
    let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
    DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeout)) { CFRunLoopStop(CFRunLoopGetMain()) }
    CFRunLoopRun()
    if let code = box.captured {
        print(code)
        return 0
    }
    fputs("ERROR timeout\n", stderr)
    return 1
}

// MARK: - UI helpers

func installAgent() -> Bool {
    let exe = currentExecutablePath()
    let plist = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key><string>local.keybridge.agent</string>
      <key>ProgramArguments</key>
      <array>
        <string>\(exe)</string>
        <string>--agent</string>
      </array>
      <key>RunAtLoad</key><true/>
      <key>KeepAlive</key><true/>
      <key>StandardOutPath</key><string>\(logPath)</string>
      <key>StandardErrorPath</key><string>\(logPath)</string>
    </dict>
    </plist>
    """
    try? plist.write(toFile: agentPlistPath, atomically: true, encoding: .utf8)
    _ = shell("/bin/launchctl", ["bootout", "gui/\(getuid())/local.keybridge.agent"])
    return shell("/bin/launchctl", ["bootstrap", "gui/\(getuid())", agentPlistPath]) == 0
}

func uninstallAgent() {
    _ = shell("/bin/launchctl", ["bootout", "gui/\(getuid())/local.keybridge.agent"])
    try? FileManager.default.removeItem(atPath: agentPlistPath)
}

func restartAgent() {
    if FileManager.default.fileExists(atPath: agentPlistPath) {
        _ = shell("/bin/launchctl", ["kickstart", "-k", "gui/\(getuid())/local.keybridge.agent"])
    } else {
        _ = installAgent()
    }
}

func agentInstalled() -> Bool { FileManager.default.fileExists(atPath: agentPlistPath) }

func runCaptureProcess() -> Int64? {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: currentExecutablePath())
    p.arguments = ["--capture", "10"]
    let out = Pipe()
    p.standardOutput = out
    p.standardError = Pipe()
    do { try p.run() } catch { return nil }
    let data = out.fileHandleForReading.readDataToEndOfFile()
    p.waitUntilExit()
    let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return Int64(text)
}

// MARK: - SwiftUI

struct Pill: View {
    let ok: Bool
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(ok ? .green : .orange).frame(width: 8, height: 8)
            Text(text).font(.caption)
        }
        .padding(.vertical, 5).padding(.horizontal, 10)
        .background(.thinMaterial, in: Capsule())
    }
}

struct MappingRow: View {
    @Binding var mapping: KeyMapping
    let onCapture: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: mapping.action.symbol)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    TextField("Nome", text: $mapping.name)
                        .font(.headline)
                        .textFieldStyle(.plain)
                    Text("code \(mapping.keyCode)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }
                Picker("Ação", selection: $mapping.action) {
                    ForEach(KeyAction.allCases) { action in
                        Text(action.title).tag(action)
                    }
                }
                .pickerStyle(.segmented)
                Text(mapping.action.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Toggle("", isOn: $mapping.enabled).labelsHidden()
            Menu {
                Button("Capturar próxima tecla", action: onCapture)
                Divider()
                Button("Remover", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ContentView: View {
    @State private var config = loadConfig()
    @State private var installed = agentInstalled()
    @State private var message = ""
    @State private var capturingID: UUID? = nil

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    setupGuide
                    mappingsSection
                    agentSection
                }
                .padding(22)
            }
        }
        .frame(width: 760, height: 680)
        .background(.ultraThinMaterial)
        .onChange(of: config.mappings) { _, _ in persistAndReload() }
    }

    var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(.blue.gradient).frame(width: 52, height: 52)
                Image(systemName: "keyboard.badge.ellipsis").font(.system(size: 26, weight: .semibold)).foregroundStyle(.white)
            }
            VStack(alignment: .leading) {
                Text("KeyBridge").font(.largeTitle.bold())
                Text("Mapeie teclas especiais de qualquer teclado para ações nativas do macOS")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Pill(ok: installed, text: installed ? "Agente no login" : "Agente não instalado")
        }
        .padding(22)
        .background(.bar)
    }

    var setupGuide: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("Como usar", systemImage: "wand.and.stars")
                    .font(.headline)
                Text("No software do seu teclado (G HUB, Synapse, iCUE, VIA, OpenLogi etc.), configure cada macro/G-key para enviar uma tecla rara, como F13–F24. Depois use “Capturar próxima tecla” aqui e escolha a ação.")
                    .foregroundStyle(.secondary)
                HStack {
                    Button("Abrir permissões") { openPermissions() }
                    Button("Abrir pasta de configuração") { NSWorkspace.shared.open(URL(fileURLWithPath: configDir)) }
                    Spacer()
                }
            }.padding(8)
        }
    }

    var mappingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mapeamentos").font(.title2.bold())
                Spacer()
                Button { addMapping() } label: { Label("Adicionar", systemImage: "plus") }
            }
            ForEach($config.mappings) { $mapping in
                MappingRow(mapping: $mapping, onCapture: { capture(mapping.id) }, onDelete: { delete(mapping.id) })
            }
        }
    }

    var agentSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Agente", systemImage: "bolt.horizontal.circle").font(.headline)
                Text("O agente é pequeno e só fica ouvindo as teclas que você configurou. Ele substitui a necessidade de usar Karabiner para este caso simples.")
                    .foregroundStyle(.secondary)
                HStack {
                    Button(installed ? "Reinstalar no login" : "Instalar no login") {
                        installed = installAgent(); message = installed ? "Agente instalado." : "Falha ao instalar agente."
                    }
                    Button("Reiniciar agente") { restartAgent(); message = "Agente reiniciado." }
                    Button("Remover agente") { uninstallAgent(); installed = false; message = "Agente removido." }
                    Spacer()
                }
                if !message.isEmpty { Text(message).font(.caption).foregroundStyle(.secondary) }
            }.padding(8)
        }
    }

    func persistAndReload() {
        saveConfig(config)
    }

    func addMapping() {
        config.mappings.append(KeyMapping(name: "Nova tecla", keyCode: 0, action: .emoji))
    }

    func delete(_ id: UUID) {
        config.mappings.removeAll { $0.id == id }
    }

    func capture(_ id: UUID) {
        capturingID = id
        message = "Aperte a tecla que deseja capturar…"
        DispatchQueue.global(qos: .userInitiated).async {
            let code = runCaptureProcess()
            DispatchQueue.main.async {
                if let idx = config.mappings.firstIndex(where: { $0.id == id }), let code {
                    config.mappings[idx].keyCode = code
                    message = "Tecla capturada: keycode \(code)."
                    restartAgent()
                } else {
                    message = "Não consegui capturar. Confira Device Control/Data Access e Input Monitoring."
                }
                capturingID = nil
            }
        }
    }

    func openPermissions() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility")!)
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
    }
}

struct KeyBridgeApp: App {
    var body: some Scene {
        WindowGroup("KeyBridge") { ContentView() }
            .windowResizability(.contentSize)
    }
}

// MARK: - Entrypoint

let args = CommandLine.arguments
if args.contains("--agent") {
    runAgent()
} else if let i = args.firstIndex(of: "--capture") {
    let timeout = (i + 1 < args.count) ? (Int(args[i + 1]) ?? 10) : 10
    exit(captureOneKey(timeout: timeout))
} else {
    KeyBridgeApp.main()
}
