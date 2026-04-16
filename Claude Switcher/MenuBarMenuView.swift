import SwiftUI

struct MenuBarMenuView: View {
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
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

        SettingsLink {
            Text("Settings…")
        }

        Divider()

        Button("Quit ClaudeSwitcher") {
            NSApplication.shared.terminate(nil)
        }
    }
}
