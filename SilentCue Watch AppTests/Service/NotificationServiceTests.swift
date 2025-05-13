import SCMock
@testable import SilentCue_Watch_App
import UserNotifications
import XCTest

final class NotificationServiceTests: XCTestCase {
    var service: MockNotificationService!

    @MainActor
    override func setUp() {
        super.setUp()
        service = MockNotificationService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // 認証リクエスト成功のテスト
    func testRequestAuthorization_Success() async {
        service.requestAuthorizationShouldSucceed = true

        let granted = await service.requestAuthorization()

        XCTAssertEqual(service.requestAuthorizationCallCount, 1)
        XCTAssertTrue(granted)
        // ステータスが更新されたか確認
        XCTAssertEqual(service.mockAuthorizationStatus, .authorized)
    }

    // 認証リクエスト失敗のテスト
    func testRequestAuthorization_Failure() async {
        service.requestAuthorizationShouldSucceed = false

        let granted = await service.requestAuthorization()

        XCTAssertEqual(service.requestAuthorizationCallCount, 1)
        XCTAssertFalse(granted)
        // ステータスはnotDetermined のままになる
        XCTAssertEqual(service.mockAuthorizationStatus, .notDetermined)
    }

    // 認証ステータス確認（認証済み、拒否済み）のテスト
    func testGetAuthorizationStatus() async {
        let testCases: [UNAuthorizationStatus] = [.authorized, .denied]

        for (index, statusToSet) in testCases.enumerated() {
            service.mockAuthorizationStatus = statusToSet

            let status = await service.getAuthorizationStatus()

            XCTAssertEqual(status, statusToSet)
        }
    }

    // 通知スケジュール（addメソッド使用）のテスト
    func testScheduleNotification_AddsRequest() async throws {
        let identifier = "testTimer"
        let content = UNMutableNotificationContent()
        content.title = "Test"
        content.body = "Test Body"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

        try await service.addNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        XCTAssertEqual(service.addRequestCallCount, 1)
        XCTAssertEqual(service.addedRequests.count, 1)
        XCTAssertEqual(service.addedRequests.first?.identifier, identifier)
        XCTAssertEqual(service.addedRequests.first?.content.title, "Test")
        XCTAssertNotNil(service.addedRequests.first?.trigger as? UNTimeIntervalNotificationTrigger)
    }

    // 通知スケジュール（addがエラーをスローする場合）のテスト
    func testScheduleNotification_ThrowsError() async {
        let identifier = "testErrorTimer"
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let expectedError = NSError(domain: "TestError", code: 123, userInfo: nil)
        service.addRequestShouldThrowError = expectedError

        do {
            try await service.addNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            XCTFail("Expected add method to throw an error, but it did not.")
        } catch {
            XCTAssertEqual(service.addRequestCallCount, 1)
            XCTAssertEqual(error as NSError, expectedError)
            XCTAssertTrue(service.addedRequests.isEmpty)
        }
    }

    // 特定の通知キャンセルテスト
    func testCancelSpecificNotification_RemovesRequest() async throws {
        // まずリクエストを追加
        let identifier1 = "timer1"
        let identifier2 = "timer2"
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        try await service.addNotificationRequest(identifier: identifier1, content: content, trigger: trigger)
        try await service.addNotificationRequest(identifier: identifier2, content: content, trigger: trigger)
        XCTAssertEqual(service.addedRequests.count, 2)

        service.removePendingNotificationRequests(withIdentifiers: [identifier1])

        XCTAssertEqual(service.removePendingRequestsCallCount, 1)
        XCTAssertEqual(service.removedRequestIdentifiers, [identifier1])
        XCTAssertEqual(service.addedRequests.count, 1)
        XCTAssertEqual(service.addedRequests.first?.identifier, identifier2)
    }

    // 全通知キャンセルテスト
    func testCancelAllNotifications_RemovesAllRequests() async throws {
        // まずいくつかのリクエストを追加
        let identifier1 = "timer1"
        let identifier2 = "timer2"
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        try await service.addNotificationRequest(identifier: identifier1, content: content, trigger: trigger)
        try await service.addNotificationRequest(identifier: identifier2, content: content, trigger: trigger)
        XCTAssertEqual(service.addedRequests.count, 2)

        service.removeAllPendingNotificationRequests()

        XCTAssertEqual(service.removeAllPendingRequestsCallCount, 1)
        XCTAssertTrue(service.removedRequestIdentifiers.contains(identifier1))
        XCTAssertTrue(service.removedRequestIdentifiers.contains(identifier2))
        XCTAssertTrue(service.addedRequests.isEmpty)
    }

    // モックの状態が正しくリセットされるかのテスト
    func testReset() async throws {
        // いくつかの状態をセットアップ
        service.mockAuthorizationStatus = .denied
        service.requestAuthorizationShouldSucceed = false
        service.addRequestShouldThrowError = NSError(domain: "Test", code: 1)
        _ = await service.requestAuthorization()
        _ = await service.getAuthorizationStatus()
        try? await service.addNotificationRequest(
            identifier: "t1",
            content: .init(),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        service.removePendingNotificationRequests(withIdentifiers: ["t1"])
        // remove all も呼び出す
        service.removeAllPendingNotificationRequests()

        // リセット
        service.reset()

        // 初期状態を検証
        XCTAssertEqual(service.requestAuthorizationCallCount, 0)
        XCTAssertEqual(service.getAuthorizationStatusCallCount, 0)
        XCTAssertEqual(service.addRequestCallCount, 0)
        XCTAssertEqual(service.removePendingRequestsCallCount, 0)
        XCTAssertEqual(service.removeAllPendingRequestsCallCount, 0)
        XCTAssertTrue(service.addedRequests.isEmpty)
        XCTAssertTrue(service.removedRequestIdentifiers.isEmpty)
        XCTAssertEqual(service.mockAuthorizationStatus, .notDetermined)
        XCTAssertTrue(service.requestAuthorizationShouldSucceed)
        XCTAssertNil(service.addRequestShouldThrowError)
    }
}
