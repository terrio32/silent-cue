import Dependencies
import Foundation
import SCProtocol
import UserNotifications

public class MockNotificationService: NotificationServiceProtocol {
    // テスト用制御プロパティ
    public var mockAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    public var requestAuthorizationShouldSucceed: Bool = true
    public var addRequestShouldThrowError: Error? = nil

    // 検証のための呼び出しとデータを追跡
    public var requestAuthorizationCallCount = 0
    public var getAuthorizationStatusCallCount = 0
    public var addRequestCallCount = 0
    public var removePendingRequestsCallCount = 0
    public var removeAllPendingRequestsCallCount = 0
    public var addedRequests: [(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger)] =
        []
    public var removedRequestIdentifiers: [String] = []

    public init() {}

    public func requestAuthorization() async -> Bool {
        requestAuthorizationCallCount += 1
        print("MockNotificationService: Requesting authorization (will return \(requestAuthorizationShouldSucceed))")
        if requestAuthorizationShouldSucceed {
            mockAuthorizationStatus = .authorized
        }
        return requestAuthorizationShouldSucceed
    }

    public func getAuthorizationStatus() async -> UNAuthorizationStatus {
        getAuthorizationStatusCallCount += 1
        print("MockNotificationService: Getting authorization status: \(mockAuthorizationStatus)")
        return mockAuthorizationStatus
    }

    public func addNotificationRequest(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger) async throws {
        addRequestCallCount += 1
        if let error = addRequestShouldThrowError {
            print("MockNotificationService: Adding request ID \(identifier) (will throw error)")
            throw error
        }
        print("MockNotificationService: Adding request ID \(identifier)")
        addedRequests.append((identifier, content, trigger))
    }

    public func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removePendingRequestsCallCount += 1
        removedRequestIdentifiers.append(contentsOf: identifiers)
        addedRequests.removeAll { identifiers.contains($0.identifier) }
        print("MockNotificationService: Removing pending requests: IDs \(identifiers)")
    }

    public func removeAllPendingNotificationRequests() {
        removeAllPendingRequestsCallCount += 1
        removedRequestIdentifiers.append(contentsOf: addedRequests.map(\.identifier))
        addedRequests.removeAll()
        print("MockNotificationService: Removing all pending requests")
    }

    // テスト用のリセット関数
    public func reset() {
        mockAuthorizationStatus = .notDetermined
        requestAuthorizationShouldSucceed = true
        addRequestShouldThrowError = nil
        requestAuthorizationCallCount = 0
        getAuthorizationStatusCallCount = 0
        addRequestCallCount = 0
        removePendingRequestsCallCount = 0
        removeAllPendingRequestsCallCount = 0
        addedRequests.removeAll()
        removedRequestIdentifiers.removeAll()
    }
}
