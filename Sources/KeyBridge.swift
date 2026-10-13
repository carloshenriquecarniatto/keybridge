import SwiftUI
import AppKit
import ApplicationServices

// MARK: - Shared model

let appName = "KeyBridge"
let bundleID = "local.keybridge.app"
let configDir = NSString(string: "~/.config/keybridge").expandingTildeInPath
let configPath = configDir + "/mappings.json"
let captureRequestPath = configDir + "/capture.request"
let captureResponsePath = configDir + "/capture.response"
let logPath = NSString(string: "~/Library/Logs/keybridge.log").expandingTildeInPath
let agentPlistPath = NSString(string: "~/Library/LaunchAgents/local.keybridge.agent.plist").expandingTildeInPath

// MARK: - Localization

let preferredLanguage = Locale.preferredLanguages.first?.split(separator: "-").first.map(String.init) ?? "en"

let strings: [String: [String: String]] = [
    "en": [
        "action.globeFn.title": "Globe/fn",
        "action.emoji.title": "Emoji",
        "action.inputSource.title": "Input Source",
        "action.disabled.title": "Disabled",
        "action.globeFn.subtitle": "Tap opens emoji; hold activates macOS tiling",
        "action.emoji.subtitle": "Opens Emoji & Symbols",
        "action.inputSource.subtitle": "Sends Ctrl+Space",
        "action.disabled.subtitle": "Ignores this key",
        "field.name": "Name",
        "field.action": "Action",
        "menu.capture": "Capture next key",
        "menu.remove": "Remove",
        "tag.agentInstalled": "Agent at login",
        "tag.agentNotInstalled": "Agent not installed",
        "subtitle": "Map special keys from any keyboard to native macOS actions",
        "guide.title": "How to use",
        "guide.body": "In your keyboard software (G HUB, Synapse, iCUE, VIA, OpenLogi, etc.), configure each macro/G-key to send a rare key such as F13–F24. Then use “Capture next key” here and choose the action.",
        "button.permissions": "Open permissions",
        "button.configFolder": "Open config folder",
        "section.mappings": "Mappings",
        "button.add": "Add",
        "section.agent": "Agent",
        "agent.body": "The agent is small and only listens for the keys you configure. It replaces the need to use Karabiner for this simple case.",
        "button.install": "Install at login",
        "button.reinstall": "Reinstall at login",
        "button.restart": "Restart agent",
        "button.removeAgent": "Remove agent",
        "message.agentInstalled": "Agent installed.",
        "message.agentInstallFailed": "Failed to install agent.",
        "message.agentRestarted": "Agent restarted.",
        "message.agentRemoved": "Agent removed.",
        "mapping.new": "New key",
        "message.capturePrompt": "Press the key you want to capture…",
        "message.captured": "Captured key: %@.",
        "message.captureFailed": "Could not capture. Check Device Control/Data Access and Input Monitoring.",
    ],
    "es": [
        "action.globeFn.title": "Globo/fn",
        "action.emoji.title": "Emoji",
        "action.inputSource.title": "Cambiar idioma",
        "action.disabled.title": "Desactivado",
        "action.globeFn.subtitle": "Tocar abre emoji; mantener activa el tiling de macOS",
        "action.emoji.subtitle": "Abre Emoji y símbolos",
        "action.inputSource.subtitle": "Envía Ctrl+Espacio",
        "action.disabled.subtitle": "Ignora esta tecla",
        "field.name": "Nombre",
        "field.action": "Acción",
        "menu.capture": "Capturar siguiente tecla",
        "menu.remove": "Eliminar",
        "tag.agentInstalled": "Agente al iniciar sesión",
        "tag.agentNotInstalled": "Agente no instalado",
        "subtitle": "Mapea teclas especiales de cualquier teclado a acciones nativas de macOS",
        "guide.title": "Cómo usar",
        "guide.body": "En el software de tu teclado (G HUB, Synapse, iCUE, VIA, OpenLogi, etc.), configura cada macro/G-key para enviar una tecla poco usada como F13–F24. Después usa “Capturar siguiente tecla” aquí y elige la acción.",
        "button.permissions": "Abrir permisos",
        "button.configFolder": "Abrir carpeta de configuración",
        "section.mappings": "Mapeos",
        "button.add": "Añadir",
        "section.agent": "Agente",
        "agent.body": "El agente es pequeño y solo escucha las teclas que configures. Sustituye la necesidad de usar Karabiner para este caso simple.",
        "button.install": "Instalar al iniciar sesión",
        "button.reinstall": "Reinstalar al iniciar sesión",
        "button.restart": "Reiniciar agente",
        "button.removeAgent": "Eliminar agente",
        "message.agentInstalled": "Agente instalado.",
        "message.agentInstallFailed": "No se pudo instalar el agente.",
        "message.agentRestarted": "Agente reiniciado.",
        "message.agentRemoved": "Agente eliminado.",
        "mapping.new": "Nueva tecla",
        "message.capturePrompt": "Pulsa la tecla que quieres capturar…",
        "message.captured": "Tecla capturada: %@.",
        "message.captureFailed": "No se pudo capturar. Revisa Device Control/Data Access e Input Monitoring.",
    ],
    "pt": [
        "action.globeFn.title": "Globo/fn",
        "action.emoji.title": "Emoji",
        "action.inputSource.title": "Trocar idioma",
        "action.disabled.title": "Desligado",
        "action.globeFn.subtitle": "Toque abre emoji; segurar ativa o tiling do macOS",
        "action.emoji.subtitle": "Abre Emoji & Símbolos",
        "action.inputSource.subtitle": "Envia Ctrl+Espaço",
        "action.disabled.subtitle": "Ignora esta tecla",
        "field.name": "Nome",
        "field.action": "Ação",
        "menu.capture": "Capturar próxima tecla",
        "menu.remove": "Remover",
        "tag.agentInstalled": "Agente no login",
        "tag.agentNotInstalled": "Agente não instalado",
        "subtitle": "Mapeie teclas especiais de qualquer teclado para ações nativas do macOS",
        "guide.title": "Como usar",
        "guide.body": "No software do seu teclado (G HUB, Synapse, iCUE, VIA, OpenLogi etc.), configure cada macro/G-key para enviar uma tecla rara, como F13–F24. Depois use “Capturar próxima tecla” aqui e escolha a ação.",
        "button.permissions": "Abrir permissões",
        "button.configFolder": "Abrir pasta de configuração",
        "section.mappings": "Mapeamentos",
        "button.add": "Adicionar",
        "section.agent": "Agente",
        "agent.body": "O agente é pequeno e só fica ouvindo as teclas que você configurou. Ele substitui a necessidade de usar Karabiner para este caso simples.",
        "button.install": "Instalar no login",
        "button.reinstall": "Reinstalar no login",
        "button.restart": "Reiniciar agente",
        "button.removeAgent": "Remover agente",
        "message.agentInstalled": "Agente instalado.",
        "message.agentInstallFailed": "Falha ao instalar agente.",
        "message.agentRestarted": "Agente reiniciado.",
        "message.agentRemoved": "Agente removido.",
        "mapping.new": "Nova tecla",
        "message.capturePrompt": "Aperte a tecla que deseja capturar…",
        "message.captured": "Tecla capturada: %@.",
        "message.captureFailed": "Não consegui capturar. Confira Device Control/Data Access e Input Monitoring.",
    ],
]

func tr(_ key: String) -> String {
    strings[preferredLanguage]?[key] ?? strings["en"]?[key] ?? key
}

func trf(_ key: String, _ args: CVarArg...) -> String {
    String(format: tr(key), arguments: args)
}

enum KeyAction: String, Codable, CaseIterable, Identifiable {
    case globeFn
    case emoji
    case inputSource
    case disabled

    var id: String { rawValue }
    var title: String {
        switch self {
        case .globeFn: return tr("action.globeFn.title")
        case .emoji: return tr("action.emoji.title")
        case .inputSource: return tr("action.inputSource.title")
        case .disabled: return tr("action.disabled.title")
        }
    }
    var subtitle: String {
        switch self {
        case .globeFn: return tr("action.globeFn.subtitle")
        case .emoji: return tr("action.emoji.subtitle")
        case .inputSource: return tr("action.inputSource.subtitle")
        case .disabled: return tr("action.disabled.subtitle")
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
    // Escrita assíncrona: o callback do event tap não pode bloquear em I/O
    // (volume de home pode ser lento; I/O síncrono aqui atrasa TODO teclado do sistema).
    logQueue.async {
        let line = "[\(Date())] \(text)\n"
        if let fh = FileHandle(forWritingAtPath: logPath) {
            defer { try? fh.close() }
            let end = fh.seekToEndOfFile()
            if end > 1_000_000 {
                fh.truncateFile(atOffset: 0) // rotação simples
            } else {
                fh.write(line.data(using: .utf8)!)
            }
        } else {
            try? line.write(toFile: logPath, atomically: true, encoding: .utf8)
        }
    }
}

let logQueue = DispatchQueue(label: "local.keybridge.log", qos: .utility)

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

// Sintetiza press/release da tecla Globe (kVK_Function, keycode 63).
// Marcar apenas a flag nos eventos não basta: os atalhos de tiling do macOS
// (Globe+Ctrl+Seta) consultam o estado global do modificador Globe.
func postGlobeState(down: Bool) {
    isPostingSynthetic = true
    defer { isPostingSynthetic = false }
    if let e = CGEvent(keyboardEventSource: nil, virtualKey: 63, keyDown: down) {
        e.type = .flagsChanged
        e.flags = down ? CGEventFlags.maskSecondaryFn : []
        e.post(tap: .cghidEventTap)
    }
}

func releaseSyntheticGlobe() {
    guard agentState.globeSynthesized else { return }
    agentState.globeSynthesized = false
    postGlobeState(down: false)
    log("Globe sintetizado ↑")
}

// MARK: - Window tiling nativo (via Accessibility)
//
// No macOS 27, os atalhos de sistema de tiling (symbolic hotkeys) não são
// acionados por eventos sintéticos de Globe — exigem o estado de hardware.
// Então o KeyBridge move/redimensiona a janela diretamente via AX API.

enum TileMode { case left, right, top, bottom, fill, center, restore }

enum WindowTiler {
    // Guarda o frame original da última janela tileada por app — usado pelo
    // Arrange "Restore" (macro + Ctrl + R).
    private static var previousFrames: [pid_t: CGRect] = [:]

    private static func readFrame(_ axWindow: AXUIElement) -> CGRect? {
        var posRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axWindow, kAXPositionAttribute as CFString, &posRef) == .success,
              AXUIElementCopyAttributeValue(axWindow, kAXSizeAttribute as CFString, &sizeRef) == .success,
              let p = posRef, let s = sizeRef else { return nil }
        var pos = CGPoint()
        var size = CGSize()
        AXValueGetValue(p as! AXValue, .cgPoint, &pos)
        AXValueGetValue(s as! AXValue, .cgSize, &size)
        return CGRect(origin: pos, size: size) // coords AX (origem topo-esquerda)
    }

    private static func setFrame(_ axWindow: AXUIElement, _ target: CGRect) -> Bool {
        // AX usa origem no topo-esquerda; Cocoa usa base-esquerda (primária = screens[0]).
        var pt = CGPoint(x: target.minX, y: NSScreen.screens[0].frame.height - target.maxY)
        var sz = CGSize(width: target.width, height: target.height)
        guard let posVal = AXValueCreate(.cgPoint, &pt), let sizeVal = AXValueCreate(.cgSize, &sz) else { return false }
        AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute as CFString, sizeVal)
        AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, posVal)
        return true
    }

    static func apply(_ mode: TileMode) -> Bool {
        guard let app = NSWorkspace.shared.frontmostApplication else { return false }
        let appEl = AXUIElementCreateApplication(app.processIdentifier)
        var windowRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appEl, kAXFocusedWindowAttribute as CFString, &windowRef) == .success,
              let window = windowRef else { return false }
        let axWindow = window as! AXUIElement

        if mode == .restore {
            guard let saved = previousFrames.removeValue(forKey: app.processIdentifier) else { return false }
            return setFrame(axWindow, saved)
        }

        guard let screen = NSScreen.main else { return false }
        let visible = screen.visibleFrame

        // Guarda o frame atual antes do primeiro tiling, para o Restore desfazer.
        if previousFrames[app.processIdentifier] == nil, let current = readFrame(axWindow) {
            let cocoaY = NSScreen.screens[0].frame.height - current.origin.y - current.height
            previousFrames[app.processIdentifier] = CGRect(x: current.minX, y: cocoaY,
                                                           width: current.width, height: current.height)
        }

        let target: CGRect
        switch mode {
        case .left: target = CGRect(x: visible.minX, y: visible.minY, width: visible.width / 2, height: visible.height)
        case .right: target = CGRect(x: visible.midX, y: visible.minY, width: visible.width / 2, height: visible.height)
        case .top: target = CGRect(x: visible.minX, y: visible.minY, width: visible.width, height: visible.height / 2)
        case .bottom: target = CGRect(x: visible.minX, y: visible.midY, width: visible.width, height: visible.height / 2)
        case .fill: target = visible
        case .center:
            let size = readFrame(axWindow)?.size ?? CGSize(width: 800, height: 600)
            target = CGRect(x: visible.midX - size.width / 2, y: visible.midY - size.height / 2,
                            width: size.width, height: size.height)
        case .restore: return false // tratado acima
        }
        return setFrame(axWindow, target)
    }
}

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
    var holdStart: Date? = nil
    var sawOtherKeyWhileHeld = false
    var globeSynthesized = false
    var loggedFirstFlaggedKey = false
    var tilingArrow: Int64? = nil
    var captureUntil: Date? = nil
    var lastConfigLoad = Date.distantPast
    var lastConfigCheck = Date.distantPast

    func reloadIfNeeded(force: Bool = false) {
        // Throttle: stat() a cada 2s no máximo (isto roda a cada tecla do sistema)
        let now = Date()
        if !force, now.timeIntervalSince(lastConfigCheck) < 2.0 { return }
        lastConfigCheck = now

        // Pedido de captura da GUI? (mesmo ciclo barato de 2s da config)
        if FileManager.default.fileExists(atPath: captureRequestPath) {
            if captureUntil == nil { captureUntil = now.addingTimeInterval(15) }
        } else {
            captureUntil = nil
        }

        let attrs = try? FileManager.default.attributesOfItem(atPath: configPath)
        let modified = attrs?[.modificationDate] as? Date ?? Date.distantPast
        guard force || modified > lastConfigLoad else { return }
        let cfg = loadConfig()
        mappingsByKeyCode = Dictionary(uniqueKeysWithValues: cfg.mappings.filter { $0.enabled }.map { ($0.keyCode, $0) })
        lastConfigLoad = Date()
        log("config carregada: \(mappingsByKeyCode.keys.sorted())")
    }
}

let agentState = AgentState()

let agentCallback: CGEventTapCallBack = { _, type, event, _ in
    if isPostingSynthetic { return Unmanaged.passUnretained(event) }

    // Modificadores (shift/ctrl/cmd) pressionados enquanto a macro está segurada
    // também recebem a flag fn — e também disparam a síntese do Globe, para que
    // o estado global Globe já esteja ativo antes da seta chegar (tiling).
    if type == .flagsChanged {
        if agentState.heldGlobeKey != nil {
            agentState.sawOtherKeyWhileHeld = true
            if !agentState.globeSynthesized {
                agentState.globeSynthesized = true
                postGlobeState(down: true)
                log("Globe sintetizado ↓ (modificador detectado)")
            }
            event.flags = CGEventFlags(rawValue: event.flags.rawValue | CGEventFlags.maskSecondaryFn.rawValue)
        }
        return Unmanaged.passUnretained(event)
    }

    guard type == .keyDown || type == .keyUp else { return Unmanaged.passUnretained(event) }
    agentState.reloadIfNeeded()

    let keycode = event.getIntegerValueField(.keyboardEventKeycode)

    // Captura de tecla pedida pela GUI: consome a próxima tecla e responde.
    if let until = agentState.captureUntil {
        if Date() >= until {
            agentState.captureUntil = nil
            try? FileManager.default.removeItem(atPath: captureRequestPath)
        } else if type == .keyDown {
            agentState.captureUntil = nil
            try? FileManager.default.removeItem(atPath: captureRequestPath)
            try? String(keycode).write(toFile: captureResponsePath, atomically: true, encoding: .utf8)
            log("captura via agente: keycode \(keycode)")
            return nil // consome: a tecla não vaza para o app em foco
        }
    }

    // Watchdog: se o keyUp da macro se perder (bug de driver/G HUB), não deixa
    // o estado fn "preso" para sempre — isso faria TODO teclado se comportar
    // como se fn estivesse segurado (setas tileiam janelas, letras viram símbolos).
    if agentState.heldGlobeKey != nil, keycode != agentState.heldGlobeKey,
       let start = agentState.holdStart, Date().timeIntervalSince(start) > 20 {
        releaseSyntheticGlobe()
        agentState.heldGlobeKey = nil
        agentState.holdStart = nil
        agentState.sawOtherKeyWhileHeld = false
        log("watchdog: limpando estado fn preso (>20s sem keyUp da macro)")
        return Unmanaged.passUnretained(event)
    }

    if let held = agentState.heldGlobeKey, keycode != held {
        agentState.sawOtherKeyWhileHeld = true
        if !agentState.globeSynthesized {
            agentState.globeSynthesized = true
            postGlobeState(down: true)
            log("Globe sintetizado ↓ (combo detectado)")
        }

        // Tiling nativo: macro + Ctrl (+Shift) + seta imita o atalho de sistema
        // Globe+Ctrl+Seta. O macOS 27 ignora Globe sintético nos symbolic hotkeys,
        // então o KeyBridge move a janela ele próprio via AX e consome o evento.
        // Halves: macro + Ctrl + seta. O macOS 27 não aplica o atalho de tiling
        // para setas com Globe sintético (a tradução fn+seta → Home/End/Page
        // captura o evento antes), então o KeyBridge executa via AX e consome.
        // Arrange (F/C/R) NÃO é interceptado: funciona nativamente (confirmado).
        let arrows: Set<Int64> = [123, 124, 125, 126]
        if arrows.contains(keycode), event.flags.contains(CGEventFlags.maskControl) {
            if type == .keyDown {
                if agentState.tilingArrow == keycode { return nil } // auto-repeat: já executou
                agentState.tilingArrow = keycode
                let mode: TileMode
                switch keycode {
                case 123: mode = .left     // ← metade esquerda
                case 124: mode = .right    // → metade direita
                case 126: mode = .top      // ↑ metade superior
                default:  mode = .bottom   // ↓ metade inferior
                }
                log("macro + Ctrl + seta \(keycode) → tiling (\(mode))")
                DispatchQueue.global(qos: .userInitiated).async {
                    if !WindowTiler.apply(mode) {
                        log("tiling falhou (sem janela focada ou app sem suporte AX)")
                    }
                }
            } else {
                if agentState.tilingArrow == keycode { agentState.tilingArrow = nil }
            }
            return nil // consome o evento (sem scroll Home/End fantasma)
        }

        if !agentState.loggedFirstFlaggedKey {
            agentState.loggedFirstFlaggedKey = true
            log("fn aplicado a key=\(keycode) (primeira do combo)")
        }
        event.flags = CGEventFlags(rawValue: event.flags.rawValue | CGEventFlags.maskSecondaryFn.rawValue)
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
                agentState.holdStart = Date()
                agentState.sawOtherKeyWhileHeld = false
                log("\(mapping.name) ↓ Globo/fn (keycode \(keycode)) — segure + setas para tiling")
            }
            return nil // consome (inclui auto-repeats, silenciosos)
        } else {
            let wasTap = (agentState.heldGlobeKey == keycode) && !agentState.sawOtherKeyWhileHeld
            releaseSyntheticGlobe()
            agentState.heldGlobeKey = nil
            agentState.holdStart = nil
            agentState.sawOtherKeyWhileHeld = false
            agentState.loggedFirstFlaggedKey = false
            if wasTap {
                log("\(mapping.name) toque → emoji")
                DispatchQueue.global(qos: .userInitiated).async { postEmoji() }
            }
            return nil
        }
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
    let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
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

// MARK: - Capture via agent
// A GUI não cria event tap próprio (não precisa de permissão!): escreve
// capture.request, o agente — que já tem Input Monitoring — captura a próxima
// tecla, consome o evento e responde em capture.response.

// MARK: - UI helpers

// Agente roda como mini-bundle PRÓPRIO (KeyBridgeAgent.app) em Application
// Support — identidade separada do app. LSUIElement: nunca aparece na Dock
// (sem ícone, sem bounce), mas tem o ícone do KeyBridge nos pedidos de
// permissão (TCC) e no Activity Monitor.
let agentSupportDir = NSString(string: "~/Library/Application Support/KeyBridge").expandingTildeInPath
var agentAppBundle: String { agentSupportDir + "/KeyBridgeAgent.app" }
var agentBinaryPath: String { agentAppBundle + "/Contents/MacOS/KeyBridgeAgent" }

func installAgent() -> Bool {
    let fm = FileManager.default
    // Monta o mini-bundle do agente a partir do app em execução
    try? fm.removeItem(atPath: agentAppBundle)
    let binDir = agentAppBundle + "/Contents/MacOS"
    let resDir = agentAppBundle + "/Contents/Resources"
    try? fm.createDirectory(atPath: binDir, withIntermediateDirectories: true)
    try? fm.createDirectory(atPath: resDir, withIntermediateDirectories: true)
    try? fm.copyItem(atPath: currentExecutablePath(), toPath: agentBinaryPath)
    if let icon = Bundle.main.url(forResource: "KeyBridgeIcon", withExtension: "icns") {
        try? fm.copyItem(at: icon, to: URL(fileURLWithPath: resDir + "/KeyBridgeIcon.icns"))
    }
    let appPlist = """
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
    """
    try? appPlist.write(toFile: agentAppBundle + "/Contents/Info.plist", atomically: true, encoding: .utf8)

    let plist = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key><string>local.keybridge.agent</string>
      <key>ProgramArguments</key>
      <array>
        <string>\(agentBinaryPath)</string>
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
    try? FileManager.default.removeItem(atPath: agentSupportDir)
}

func restartAgent() {
    // Reinstala: remonta o bundle do agente com o binário atual e reinicia.
    _ = installAgent()
}

func agentInstalled() -> Bool { FileManager.default.fileExists(atPath: agentPlistPath) }

// MARK: - SwiftUI

/// Nome legível da tecla a partir do virtual keycode do macOS (ex.: 113 → "F15").
func keyName(_ code: Int64) -> String {
    let names: [Int64: String] = [
        // Letras (US)
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V", 11: "B",
        12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 31: "O", 32: "U", 34: "I", 35: "P",
        37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 45: "N", 46: "M",
        // Números e símbolos
        18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7",
        27: "-", 28: "8", 29: "0", 30: "]", 33: "[", 42: "\\", 43: ",", 44: "/", 47: ".", 50: "`",
        // Especiais
        36: "Return", 48: "Tab", 49: "Space", 51: "Delete", 53: "Esc", 57: "Caps Lock",
        55: "Cmd", 56: "Shift", 58: "Option", 59: "Ctrl", 60: "Right Shift", 61: "Right Option", 62: "Right Ctrl",
        63: "Globe/fn", 72: "Vol +", 73: "Vol −", 74: "Mute",
        // Setas
        123: "←", 124: "→", 125: "↓", 126: "↑",
        // Função
        122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6", 98: "F7", 100: "F8",
        101: "F9", 109: "F10", 103: "F11", 111: "F12", 105: "F13", 107: "F14", 113: "F15",
        106: "F16", 64: "F17", 79: "F18", 80: "F19", 90: "F20",
        // Teclado numérico
        65: "Pad .", 67: "Pad ×", 69: "Pad +", 71: "Pad ⌫", 75: "Pad /", 76: "Pad ⏎",
        78: "Pad −", 81: "Pad =", 82: "Pad 0", 83: "Pad 1", 84: "Pad 2", 85: "Pad 3",
        86: "Pad 4", 87: "Pad 5", 88: "Pad 6", 89: "Pad 7", 91: "Pad 8", 92: "Pad 9"
    ]
    return names[code] ?? "code \(code)"
}

// MARK: Liquid Glass (macOS 26+) com fallback para materiais

extension View {
    @ViewBuilder
    func glassCard(in shape: some Shape, fallback: Material = .regularMaterial) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(fallback, in: shape)
        }
    }

    @ViewBuilder
    func glassButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            self
        }
    }
}

struct Pill: View {
    let ok: Bool
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(ok ? .green : .orange).frame(width: 8, height: 8)
            Text(text).font(.caption)
        }
        .padding(.vertical, 5).padding(.horizontal, 10)
        .glassCard(in: Capsule(), fallback: .thinMaterial)
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
                    TextField(tr("field.name"), text: $mapping.name)
                        .font(.headline)
                        .textFieldStyle(.plain)
                    Text(keyName(mapping.keyCode))
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }
                Picker(tr("field.action"), selection: $mapping.action) {
                    ForEach(KeyAction.allCases) { action in
                        Text(action.title).tag(action)
                    }
                }
                .pickerStyle(.segmented)
                Text(mapping.action.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Toggle("", isOn: $mapping.enabled).labelsHidden()
            Menu {
                Button(tr("menu.capture"), action: onCapture)
                Divider()
                Button(tr("menu.remove"), role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(14)
        .glassCard(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                Text(tr("subtitle"))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Pill(ok: installed, text: installed ? tr("tag.agentInstalled") : tr("tag.agentNotInstalled"))
        }
        .padding(22)
        .background(.bar)
    }

    var setupGuide: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label(tr("guide.title"), systemImage: "wand.and.stars")
                    .font(.headline)
                Text(tr("guide.body"))
                    .foregroundStyle(.secondary)
                HStack {
                    Button(tr("button.permissions")) { openPermissions() }
                        .glassButtonStyle()
                    Button(tr("button.configFolder")) { NSWorkspace.shared.open(URL(fileURLWithPath: configDir)) }
                        .glassButtonStyle()
                    Spacer()
                }
            }.padding(8)
        }
    }

    var mappingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tr("section.mappings")).font(.title2.bold())
                Spacer()
                Button { addMapping() } label: { Label(tr("button.add"), systemImage: "plus") }
                    .glassButtonStyle(prominent: true)
            }
            ForEach($config.mappings) { $mapping in
                MappingRow(mapping: $mapping, onCapture: { capture(mapping.id) }, onDelete: { delete(mapping.id) })
            }
        }
    }

    var agentSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label(tr("section.agent"), systemImage: "bolt.horizontal.circle").font(.headline)
                Text(tr("agent.body"))
                    .foregroundStyle(.secondary)
                HStack {
                    Button(installed ? tr("button.reinstall") : tr("button.install")) {
                        installed = installAgent(); message = installed ? tr("message.agentInstalled") : tr("message.agentInstallFailed")
                    }
                    .glassButtonStyle(prominent: true)
                    Button(tr("button.restart")) { restartAgent(); message = tr("message.agentRestarted") }
                        .glassButtonStyle()
                    Button(tr("button.removeAgent")) { uninstallAgent(); installed = false; message = tr("message.agentRemoved") }
                        .glassButtonStyle()
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
        config.mappings.append(KeyMapping(name: tr("mapping.new"), keyCode: 0, action: .emoji))
    }

    func delete(_ id: UUID) {
        config.mappings.removeAll { $0.id == id }
    }

    func capture(_ id: UUID) {
        capturingID = id
        message = tr("message.capturePrompt")
        try? FileManager.default.removeItem(atPath: captureResponsePath)
        try? "".write(toFile: captureRequestPath, atomically: true, encoding: .utf8)
        DispatchQueue.global(qos: .userInitiated).async {
            let deadline = Date().addingTimeInterval(12)
            var code: Int64? = nil
            while Date() < deadline {
                if let raw = try? String(contentsOfFile: captureResponsePath, encoding: .utf8),
                   let c = Int64(raw.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    code = c
                    break
                }
                Thread.sleep(forTimeInterval: 0.15)
            }
            try? FileManager.default.removeItem(atPath: captureRequestPath)
            try? FileManager.default.removeItem(atPath: captureResponsePath)
            DispatchQueue.main.async {
                if let idx = config.mappings.firstIndex(where: { $0.id == id }), let code {
                    config.mappings[idx].keyCode = code
                    message = trf("message.captured", keyName(code))
                    // mappings.json é recarregado sozinho pelo agente (hot reload)
                } else {
                    message = tr("message.captureFailed")
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
    // Agente é um mini-bundle próprio fora do app — sem Dock, sem bounce.
    runAgent()
} else {
    KeyBridgeApp.main()
}
