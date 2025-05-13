import ComposableArchitecture
import SCMock
import SCProtocol
import SCShared
@testable import SilentCue_Watch_App
import WatchKit
import XCTest

@MainActor
final class HapticsReducerTests: XCTestCase {
    var store: TestStore<HapticsState, HapticsAction>!
    var mockHaptics: MockHapticsService!
    var clock: TestClock<Duration>!

    override func setUp() {
        super.setUp()
        mockHaptics = MockHapticsService()
        clock = TestClock<Duration>()
        store = TestStore(
            initialState: HapticsState(),
            reducer: { HapticsReducer() },
            withDependencies: { dependencies in
                dependencies.hapticsService = self.mockHaptics
                dependencies.continuousClock = self.clock
            }
        )
    }

    override func tearDown() {
        store = nil
        mockHaptics = nil
        clock = nil
        super.tearDown()
    }

    func testUpdateHapticSettings() async {
        await store.send(.updateHapticSettings(type: .strong)) {
            $0.hapticType = .strong
        }
        await store.finish()
    }

    func testStartAndStopHaptic() async {
        await store.send(.startHaptic(.weak)) {
            $0.isActive = true
            $0.hapticType = .weak
        }
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, 1)
        XCTAssertEqual(mockHaptics.lastPlayedHapticType, HapticType.weak.wkHapticType)

        await clock.advance(by: .seconds(1))
        XCTAssertEqual(mockHaptics.playCallCount, 1)

        await store.send(.stopHaptic) {
            $0.isActive = false
        }

        await store.finish()
    }

    // --- Haptic Preview Tests ---

    func testStartPreview_StartsPreviewAndPlaysHaptic() async {
        let previewType = HapticType.standard
        await store.send(.startPreview(previewType)) {
            $0.isPreviewingHaptic = true
            $0.previewTargetHapticType = previewType
        }
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, 1, "Preview starts with one haptic play")
        XCTAssertEqual(mockHaptics.lastPlayedHapticType, previewType.wkHapticType)

        await store.skipInFlightEffects()
        await store.finish(timeout: .seconds(0.1))
    }

    func testHapticPreview_TicksAndPlaysHaptic() async {
        let previewType = HapticType.standard
        await store.send(.startPreview(previewType)) {
            $0.isPreviewingHaptic = true
            $0.previewTargetHapticType = previewType
        }
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, 1)

        await clock.advance(by: .seconds(previewType.interval))
        await store.receive(.previewTick)
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, 2, "Haptic plays on tick")
        XCTAssertEqual(mockHaptics.lastPlayedHapticType, previewType.wkHapticType)
        XCTAssertTrue(store.state.isPreviewingHaptic)

        await store.skipInFlightEffects()
        await store.finish(timeout: .seconds(0.1))
    }

    func testHapticPreview_TimesOutAndStops() async {
        let previewType = HapticType.short
        let previewTimeoutDuration: Duration = .seconds(3)

        await store.send(.startPreview(previewType)) {
            $0.isPreviewingHaptic = true
            $0.previewTargetHapticType = previewType
        }
        await Task.yield()
        let initialPlayCount = mockHaptics.playCallCount

        var elapsed: Duration = .zero
        var tickCount = 0
        while elapsed + .seconds(previewType.interval) < previewTimeoutDuration {
            await clock.advance(by: .seconds(previewType.interval))
            await store.receive(.previewTick)
            await Task.yield()
            tickCount += 1
            elapsed += .seconds(previewType.interval)
        }

        await clock.advance(by: previewTimeoutDuration - elapsed + .nanoseconds(1))
        await store.receive(.stopPreview) {
            $0.isPreviewingHaptic = false
            $0.previewTargetHapticType = nil
        }
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, initialPlayCount + tickCount, "Total plays should be initial + ticks before timeout")

        await clock.advance(by: .seconds(previewType.interval * 2))
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, initialPlayCount + tickCount, "No haptic plays after timeout")
        await store.finish()
    }

    func testStopPreview_ManuallyStopsAndCancelsTimers() async {
        let previewType = HapticType.standard
        await store.send(.startPreview(previewType)) {
            $0.isPreviewingHaptic = true
            $0.previewTargetHapticType = previewType
        }
        await Task.yield()
        let playCountAfterStart = mockHaptics.playCallCount

        await clock.advance(by: .milliseconds(100))

        await store.send(.stopPreview) {
            $0.isPreviewingHaptic = false
            $0.previewTargetHapticType = nil
        }
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, playCountAfterStart, "No additional haptic plays after manual stop")

        await clock.advance(by: .seconds(previewType.interval * 2))
        await Task.yield()
        XCTAssertEqual(mockHaptics.playCallCount, playCountAfterStart, "No haptic plays after manual stop and time advance")
        await store.finish()
    }

    func testStartPreview_OverridesExistingPreview() async {
        let typeA = HapticType.standard
        let typeB = HapticType.short

        await store.send(.startPreview(typeA)) {
            $0.isPreviewingHaptic = true
            $0.previewTargetHapticType = typeA
        }
        await Task.yield()
        XCTAssertEqual(mockHaptics.lastPlayedHapticType, typeA.wkHapticType)
        let playCountAfterTypeAStart = mockHaptics.playCallCount

        await clock.advance(by: .milliseconds(200))

        await store.send(.startPreview(typeB)) {
            $0.previewTargetHapticType = typeB
        }
        await Task.yield()
        XCTAssertEqual(mockHaptics.lastPlayedHapticType, typeB.wkHapticType, "Should play typeB now")
        XCTAssertEqual(mockHaptics.playCallCount, playCountAfterTypeAStart + 1, "Play count increments for typeB's first play")

        await clock.advance(by: .seconds(typeB.interval))
        await store.receive(.previewTick)
        await Task.yield()
        XCTAssertEqual(mockHaptics.lastPlayedHapticType, typeB.wkHapticType, "Tick should play typeB")
        XCTAssertEqual(mockHaptics.playCallCount, playCountAfterTypeAStart + 2)

        await store.skipInFlightEffects()
        await store.finish(timeout: .seconds(0.1))
    }
}
