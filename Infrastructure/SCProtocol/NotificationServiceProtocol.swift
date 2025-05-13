import Foundation
import UserNotifications

public protocol NotificationServiceProtocol {
    func requestAuthorization() async -> Bool
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    func addNotificationRequest(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
}
