import ComposableArchitecture
import SCMock
import SCShared
@testable import SilentCue_Watch_App
import WatchKit
import XCTest

@MainActor
final class SettingsReducerTests: XCTestCase {
    var store: TestStore<SettingsState, SettingsAction>!
    var mockUserDefaults: MockUserDefaultsManager!
    var mockHaptics: MockHapticsService!
    var clock: TestClock<Duration>!

    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaultsManager()
        mockHaptics = MockHapticsService()
        clock = TestClock<Duration>()
        store = TestStore(
            initialState: SettingsState(),
            reducer: { SettingsReducer() },
            withDependencies: { dependencies in
                dependencies.userDefaultsService = self.mockUserDefaults
                dependencies.hapticsService = self.mockHaptics
                dependencies.continuousClock = self.clock
            }
        )
    }

    override func tearDown() {
        store = nil
        mockUserDefaults = nil
        mockHaptics = nil
        clock = nil
        super.tearDown()
    }

    // UserDefaults に値が存在しない場合に設定をロードする
    func testLoadSettings_Default() async {
        mockUserDefaults.remove(forKey: .hapticType)
        await store.send(SettingsAction.loadSettings)
        await store.receive(SettingsAction.settingsLoaded(hapticType: HapticType.standard)) {
            $0.selectedHapticType = HapticType.standard
            $0.isSettingsLoaded = true
        }
        await store.finish()
    }

    // UserDefaults に値が存在する場合に設定をロードする
    func testLoadSettings_ExistingValue() async {
        mockUserDefaults.set(HapticType.strong.rawValue, forKey: .hapticType)
        await store.send(SettingsAction.loadSettings)
        await store.receive(SettingsAction.settingsLoaded(hapticType: HapticType.strong)) {
            $0.selectedHapticType = HapticType.strong
            $0.isSettingsLoaded = true
        }
        await store.finish()
    }

    // ハプティクスタイプを選択すると保存がトリガーされる
    func testSelectHapticType_TriggersSave() async {
        let selectedType = HapticType.weak
        await store.send(SettingsAction.selectHapticType(selectedType)) {
            $0.selectedHapticType = selectedType
        }

        await store.receive(.saveSettings)
        await Task.yield()
        XCTAssertEqual(
            mockUserDefaults.object(forKey: .hapticType) as? String,
            selectedType.rawValue,
            "UserDefaults が更新されていること"
        )

        await store.finish()
    }
}
