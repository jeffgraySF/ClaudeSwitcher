import SwiftUI
import AppKit

struct MenuBarMenuView: View {
    @Environment(ProfileManager.self) var profileManager
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Text("Claude Switcher")
            .font(.headline)
            .foregroundStyle(.secondary)

        Divider()

        // Picker gives us native checkmarks for free
        Picker("Account", selection: Binding(
            get: { profileManager.activeProfileID },
            set: { newID in
                profileManager.activeProfileID = newID
                if let id = newID,
                   let profile = profileManager.profiles.first(where: { $0.id == id }) {
                    profileManager.launchClaude(for: profile)
                }
            }
        )) {
            ForEach(profileManager.profiles) { profile in
                Text(profile.emoji + "  " + profile.name)
                    .tag(Optional(profile.id))
            }
        }
        .pickerStyle(.inline)

        Divider()

        Button("Settings…") {
            openSettings()
            NSApp.activate(ignoringOtherApps: true)
        }

        Divider()

        Button("Quit ClaudeSwitcher") {
            NSApplication.shared.terminate(nil)
        }
    }
}
