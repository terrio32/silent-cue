import SwiftUI
import ComposableArchitecture
import SCCoordinator

@main
struct SilentCueWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    let store = Store(
        initialState: SCCoordinator.State(),
        reducer: { SCCoordinator() }
    )

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: ViewStore(store).binding(
                get: \.path,
                send: { .navigationPathChanged($0) }
            )) {
                SetTimerView()
                    .navigationDestination(for: SetTimerView.self) { _ in
                        SetTimerView()
                    }
                    .navigationDestination(for: SettingsView.self) { _ in
                        SettingsView()
                    }
                    .navigationDestination(for: CountdownView.self) { _ in
                        CountdownView()
                    }
                    .navigationDestination(for: TimerCompletionView.self) { _ in
                        TimerCompletionView()
                    }
            }
        }
    }
}
