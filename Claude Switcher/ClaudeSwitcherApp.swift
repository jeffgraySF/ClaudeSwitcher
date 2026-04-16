import SwiftUI
import ServiceManagement

@main
struct ClaudeSwitcherApp: App {
    @State private var profileManager = ProfileManager()

    init() {
        try? SMAppService.mainApp.register()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView()
                .environment(profileManager)
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environment(profileManager)
        }
    }
}
