import Foundation
import AppKit
import Observation
import SwiftUI

struct Profile: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var configDir: String
    var emoji: String
}

@Observable
class ProfileManager {
    var profiles: [Profile] {
        didSet { save() }
    }

    var activeProfileID: UUID? {
        didSet {
            UserDefaults.standard.set(activeProfileID?.uuidString, forKey: "activeProfileID")
        }
    }

    var activeProfile: Profile? {
        profiles.first { $0.id == activeProfileID }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "profiles"),
           let decoded = try? JSONDecoder().decode([Profile].self, from: data) {
            self.profiles = decoded
        } else {
            // Default profiles — rename and adjust config dirs in Settings
            self.profiles = [
                Profile(name: "Personal",  configDir: "~/.claude-personal",  emoji: "👤"),
                Profile(name: "Work",      configDir: "~/.claude-work",      emoji: "💼"),
                Profile(name: "Freelance", configDir: "~/.claude-freelance", emoji: "⭐️")
            ]
        }

        if let idString = UserDefaults.standard.string(forKey: "activeProfileID"),
           let id = UUID(uuidString: idString) {
            self.activeProfileID = id
        }
    }

    /// Opens a folder picker, then launches Claude Code in a new Terminal window with
    /// CLAUDE_CONFIG_DIR set. Never reads, writes, or swaps credential files.
    func launchClaude(for profile: Profile) {
        let expandedDir = NSString(string: profile.configDir).expandingTildeInPath
        try? FileManager.default.createDirectory(atPath: expandedDir, withIntermediateDirectories: true)

        let panel = NSOpenPanel()
        panel.title = "Choose project folder"
        panel.message = "Opening Claude Code as \(profile.name)"
        panel.prompt = "Open in Terminal"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())

        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let shellScript = """
        #!/bin/bash
        printf '\\033]1;\(profile.name)\\007'
        cd '\(url.path.replacingOccurrences(of: "'", with: "'\\''"))'
        export CLAUDE_CONFIG_DIR='\(expandedDir.replacingOccurrences(of: "'", with: "'\\''"))'
        claude
        exec $SHELL
        """
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".command")
        try? shellScript.write(to: tempURL, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempURL.path)
        NSWorkspace.shared.open(tempURL)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            try? FileManager.default.removeItem(at: tempURL)
        }
    }

    func addProfile() {
        profiles.append(Profile(name: "New Account", configDir: "~/.claude-new", emoji: "⭐️"))
    }

    func deleteProfile(at offsets: IndexSet) {
        profiles.remove(atOffsets: offsets)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: "profiles")
        }
    }
}
