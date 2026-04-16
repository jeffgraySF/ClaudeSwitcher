import Foundation
import AppKit

struct Profile: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var configDir: String
    var emoji: String
}

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] {
        didSet { save() }
    }

    @Published var activeProfileID: UUID? {
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

    // Opens a new Terminal window with CLAUDE_CONFIG_DIR set — never reads credentials.
    /// Opens a new Terminal window with CLAUDE_CONFIG_DIR pointed at this profile's folder.
    /// This app never reads, writes, or swaps credential files.
    func launchClaude(for profile: Profile) {
        let expandedDir = NSString(string: profile.configDir).expandingTildeInPath

        // Create the config dir if it doesn't exist yet
        try? FileManager.default.createDirectory(
            atPath: expandedDir,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let source = """
        tell application "Terminal"
            activate
            do script "CLAUDE_CONFIG_DIR='\(expandedDir)' claude"
        end tell
        """
        var error: NSDictionary?
        NSAppleScript(source: source)?.executeAndReturnError(&error)
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
