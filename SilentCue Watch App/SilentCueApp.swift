import ComposableArchitecture
import SCShared
import SwiftUI
import UserNotifications

#if DEBUG
    import SCPreview
#endif

@main
struct SilentCueWatchApp: App {
    let store: StoreOf<CoordinatorReducer>
    @Environment(\.scenePhase) private var scenePhase
    let notificationDelegate: NotificationDelegate

    init() {
        #if DEBUG
            if CommandLine.arguments.contains(SCAppEnvironment.LaunchArguments.uiTesting.rawValue) {
                print("--- UI Testing: Initializing Store with overridden dependencies (DEBUG build) ---")
                store = Store(initialState: CoordinatorState()) {
                    CoordinatorReducer()
                } withDependencies: { dependencies in
                    dependencies.userDefaultsService = PreviewUserDefaultsService()
                    dependencies.notificationService = PreviewNotificationService()
                    dependencies.extendedRuntimeService = PreviewExtendedRuntimeService()
                    dependencies.hapticsService = PreviewHapticsService()
                }
            } else {
                store = Store(initialState: CoordinatorState()) {
                    CoordinatorReducer()
                }
            }
        #else
            store = Store(initialState: CoordinatorState()) {
                CoordinatorReducer()
            }
        #endif

        notificationDelegate = NotificationDelegate(store: store)
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            WithViewStore(store, observe: { $0 }, content: { viewStore in
                NavigationStack(path: viewStore.binding(
                    get: \.path,
                    send: CoordinatorAction.pathChanged
                )) {
                    SetTimerView(
                        store: store.scope(state: \.timer, action: \.timer),
                        onSettingsButtonTapped: {
                            viewStore.send(.pushScreen(.settings))
                        },
                        onTimerStart: {
                            viewStore.send(.pushScreen(.countdown))
                        }
                    )
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                            case .countdown:
                                CountdownView(
                                    store: store.scope(state: \.timer, action: \.timer)
                                )
                            case .completion:
                                TimerCompletionView(
                                    store: store.scope(state: \.timer, action: \.timer)
                                )
                                .navigationBarBackButtonHidden(true)
                            case .settings:
                                SettingsView(
                                    store: store.scope(state: \.settings, action: \.settings),
                                    hapticsStore: store.scope(
                                        state: \.haptics,
                                        action: \.haptics
                                    )
                                )
                            case .timerStart:
                                EmptyView()
                        }
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    viewStore.send(.scenePhaseChanged(newPhase))
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .alert("通知について", isPresented: viewStore.binding(
                    get: \.shouldShowNotificationAlert,
                    send: { .setNotificationAlert(isPresented: $0) }
                )) {
                    Button("許可する") {
                        viewStore.send(.notificationAlertPermitTapped)
                    }
                    Button("許可しない", role: .cancel) {
                        viewStore.send(.notificationAlertDenyTapped)
                    }
                } message: {
                    Text("\nタイマー完了時に通知を受け取りますか？\n\n通知を許可すると、アプリが閉じていても完了をお知らせします。\n")
                }
            })
        }
    }
}

// 通知処理
class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    private let store: Store<CoordinatorState, CoordinatorAction>

    init(store: Store<CoordinatorState, CoordinatorAction>) {
        self.store = store
        super.init()
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let categoryIdentifier = response.notification.request.content.categoryIdentifier

        if categoryIdentifier == "TIMER_COMPLETED_CATEGORY" {
            handleTimerCompletionNotification()
        }

        completionHandler()
    }

    private func handleTimerCompletionNotification() {
        print("Timer completion notification received.")
    }
}
