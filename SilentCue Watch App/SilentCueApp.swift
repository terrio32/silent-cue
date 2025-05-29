import SwiftUI

@main
struct SilentCueWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SetTimerView(
                    onSettingsButtonTapped: {},
                    onTimerStart: {}
                )
                .navigationDestination(for: String.self) { destination in
                    switch destination {
                        case "countdown":
                            CountdownView()
                        case "completion":
                            TimerCompletionView()
                        case "settings":
                            SettingsView()
                        default:
                            EmptyView()
                    }
                }
            }
        }
    }
}
