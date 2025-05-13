#if DEBUG

    import Dependencies
    import Foundation
    import SCProtocol
    import UserNotifications

    public class PreviewNotificationService: NotificationServiceProtocol {
        public var authorizationStatus: UNAuthorizationStatus = .notDetermined
        private var addedRequests: [String] = []

        public init() {}

        public func requestAuthorization() async -> Bool {
            authorizationStatus = .authorized
            return true
        }

        public func getAuthorizationStatus() async -> UNAuthorizationStatus {
            authorizationStatus
        }

        public func addNotificationRequest(
            identifier: String,
            content _: UNNotificationContent,
            trigger _: UNNotificationTrigger
        ) async throws {
            addedRequests.append(identifier)
        }

        public func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
            addedRequests.removeAll { identifiers.contains($0) }
        }

        public func removeAllPendingNotificationRequests() {
            addedRequests.removeAll()
        }
    }

#endif
