import ComposableArchitecture
import SCProtocol

extension DependencyValues {
    var userDefaultsService: UserDefaultsServiceProtocol {
        get { self[UserDefaultsServiceKey.self] }
        set { self[UserDefaultsServiceKey.self] = newValue }
    }

    var hapticsService: HapticsServiceProtocol {
        get { self[HapticsServiceKey.self] }
        set { self[HapticsServiceKey.self] = newValue }
    }

    var notificationService: NotificationServiceProtocol {
        get { self[NotificationServiceKey.self] }
        set { self[NotificationServiceKey.self] = newValue }
    }

    var extendedRuntimeService: ExtendedRuntimeServiceProtocol {
        get { self[ExtendedRuntimeServiceKey.self] }
        set { self[ExtendedRuntimeServiceKey.self] = newValue }
    }
}
