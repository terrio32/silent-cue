import ComposableArchitecture
import SCMock
import SCShared
@testable import SilentCue_Watch_App
import XCTest

@MainActor
final class CoordinatorReducerTests: XCTestCase {
    var store: TestStore<CoordinatorState, CoordinatorAction>!

    override func setUp() {
        super.setUp()
        store = TestStore(
            initialState: CoordinatorState(),
            reducer: { CoordinatorReducer() },
            withDependencies: {
                $0.userDefaultsService = MockUserDefaultsManager()
                $0.notificationService = MockNotificationService()
                $0.hapticsService = MockHapticsService()
                $0.date = .constant(Date(timeIntervalSince1970: 0))
            }
        )
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    func testOnAppearLoadsSettings() async {
        let mockUserDefaults = MockUserDefaultsManager()
        mockUserDefaults.set(HapticType.standard.rawValue, forKey: UserDefaultsKeys.hapticType)
        mockUserDefaults.set(false, forKey: UserDefaultsKeys.isFirstLaunch)

        store.dependencies.userDefaultsService = mockUserDefaults
        store.dependencies.notificationService = MockNotificationService()

        store = TestStore(
            initialState: CoordinatorState(),
            reducer: { CoordinatorReducer() },
            withDependencies: { $0 = store.dependencies }
        )

        await store.send(CoordinatorAction.onAppear)

        await store.receive(.settings(.loadSettings))

        await store.receive(CoordinatorAction.settings(.settingsLoaded(
            hapticType: HapticType.standard
        ))) { state in
            state.settings.selectedHapticType = HapticType.standard
            state.settings.isSettingsLoaded = true
        }

        await store.receive(.haptics(.updateHapticSettings(type: .standard)))

        await store.finish()
    }

    func testSettingsLoadedUpdatesHaptics() async {
        let loadedAction = SettingsAction.settingsLoaded(hapticType: HapticType.weak)
        await store.send(CoordinatorAction.settings(loadedAction)) { state in
            state.settings.selectedHapticType = HapticType.weak
            state.settings.isSettingsLoaded = true
        }

        await store.receive(CoordinatorAction.haptics(.updateHapticSettings(
            type: HapticType.weak
        ))) { state in
            state.haptics.hapticType = HapticType.weak
        }

        await store.finish()
    }

    func testDismissCompletionViewClearsPathAndStopsHaptic() async {
        var initialState = CoordinatorState()
        initialState.timer.completionDate = Date()

        store = TestStore(
            initialState: initialState,
            reducer: { CoordinatorReducer() },
            withDependencies: { $0 = store.dependencies }
        )

        await store.send(CoordinatorAction.timer(.dismissCompletionView)) { state in
            state.path = []
            state.timer.completionDate = nil
        }

        await store.receive(CoordinatorAction.haptics(.stopHaptic))

        store.assert { state in
            state.haptics.isActive = false
        }
        await store.finish()
    }

    // MARK: - Haptic Preview Coordination Tests

    func testCoordinator_WhenSettingsSelectHapticType_SendsHapticsStartPreview() async {
        let selectedType = HapticType.strong

        await store.send(.settings(.selectHapticType(selectedType))) { state in
            state.settings.selectedHapticType = selectedType
        }

        await store.receive(.haptics(.startPreview(selectedType))) { state in
            state.haptics.isPreviewingHaptic = true
            state.haptics.previewTargetHapticType = selectedType
        }

        await store.skipInFlightEffects()
        await store.finish(timeout: .seconds(0.1))
    }

    func testCoordinator_WhenSettingsBackButtonTapped_AndPreviewActive_SendsHapticsStopPreviewAndPopsScreen() async {
        let previewType = HapticType.standard
        var initialState = CoordinatorState()
        initialState.settings.selectedHapticType = previewType
        initialState.haptics.isPreviewingHaptic = true
        initialState.haptics.previewTargetHapticType = previewType
        initialState.path = [.settingsScreen]

        store = TestStore(
            initialState: initialState,
            reducer: { CoordinatorReducer() },
            withDependencies: { $0 = self.store.dependencies }
        )

        await store.send(.settings(.backButtonTapped))

        await store.receive(.haptics(.stopPreview)) { state in
            state.haptics.isPreviewingHaptic = false
            state.haptics.previewTargetHapticType = nil
        }

        await store.receive(.popScreen) { state in
            state.path.removeLast()
        }

        await store.finish()
    }

    func testCoordinator_WhenSettingsBackButtonTapped_AndPreviewInactive_PopsScreenOnly() async {
        var initialState = CoordinatorState()
        initialState.haptics.isPreviewingHaptic = false
        initialState.path = [.settingsScreen]

        store = TestStore(
            initialState: initialState,
            reducer: { CoordinatorReducer() },
            withDependencies: { $0 = self.store.dependencies }
        )

        await store.send(.settings(.backButtonTapped))

        await store.receive(.popScreen) { state in
            state.path.removeLast()
        }

        await store.finish()
    }
}
