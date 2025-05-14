import Combine
import ComposableArchitecture
import SCMock
@testable import SilentCue_Watch_App
import WatchKit
import XCTest

final class ExtendedRuntimeServiceTests: XCTestCase {
    var service: MockExtendedRuntimeService!

    override func setUp() {
        super.setUp()
        service = MockExtendedRuntimeService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // セッション開始時のパラメータ記録を検証
    func testStartSession_RecordsParameters() {
        let testDuration: TimeInterval = 120
        let testEndDate = Date().addingTimeInterval(testDuration)

        // startSession 呼び出し (completionHandler なし)
        service.startSession(duration: testDuration, targetEndTime: testEndDate)

        XCTAssertEqual(service.startSessionCallCount, 1)
        XCTAssertEqual(service.lastStartSessionDuration, testDuration)
        XCTAssertEqual(service.lastStartSessionTargetEndTime, testEndDate)
    }

    // セッション停止が記録されるか検証
    func testStopSession_IncrementsCallCount() {
        service.stopSession()
        XCTAssertEqual(service.stopSessionCallCount, 1)
    }

    // モックの状態リセットを検証
    func testReset() {
        // startSession 呼び出し (completionHandler なし)
        service.startSession(duration: 10, targetEndTime: nil)
        service.stopSession()

        service.reset()

        XCTAssertEqual(service.startSessionCallCount, 0)
        XCTAssertNil(service.lastStartSessionDuration)
        XCTAssertNil(service.lastStartSessionTargetEndTime)
        XCTAssertEqual(service.stopSessionCallCount, 0)
    }
}
