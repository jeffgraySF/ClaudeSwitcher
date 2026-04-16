import SwiftUI

@main
struct ClaudeSwitcherApp: App {
    @StateObject private var profileManager = ProfileManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView()
                .environmentObject(profileManager)
        } label: {
            Text(profileManager.activeProfile?.emoji ?? "👤")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environmentObject(profileManager)
        }
    }
}
