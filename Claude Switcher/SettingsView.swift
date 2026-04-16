import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                ForEach($profileManager.profiles) { $profile in
                    HStack(spacing: 12) {
                        TextField("", text: $profile.emoji)
                            .frame(width: 32)
                            .multilineTextAlignment(.center)

                        TextField("Name", text: $profile.name)
                            .frame(width: 120)

                        TextField("~/.claude-...", text: $profile.configDir)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                .onDelete(perform: profileManager.deleteProfile)
            }

            HStack {
                Button {
                    profileManager.addProfile()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                .padding(8)

                Spacer()

                Text("Swipe left to delete a profile")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
            }

            Divider()

            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)
                Text("This app never reads your credentials. Each profile is an isolated config folder.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(width: 500, height: 280)
        .navigationTitle("ClaudeSwitcher")
    }
}
