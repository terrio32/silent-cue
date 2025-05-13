#if DEBUG

    import Dependencies
    import Foundation
    import SCProtocol
    import SCShared

    public class PreviewUserDefaultsService: UserDefaultsServiceProtocol {
        private var storage: [String: Any] = [:]

        public init() {
            storage = [
                UserDefaultsKeys.hapticType.rawValue: HapticType.standard.rawValue,
                UserDefaultsKeys.isFirstLaunch.rawValue: true,
            ]
        }

        public func set(_: Any?, forKey _: UserDefaultsKeys) {}

        public func object(forKey defaultName: UserDefaultsKeys) -> Any? {
            storage[defaultName.rawValue]
        }

        public func remove(forKey _: UserDefaultsKeys) {}

        public func removeAll() {
            storage.removeAll()
        }

        public func saveHapticType(_ type: HapticType) {
            storage[UserDefaultsKeys.hapticType.rawValue] = type.rawValue
        }

        public func loadHapticType() -> HapticType {
            (storage[UserDefaultsKeys.hapticType.rawValue] as? String)
                .flatMap { HapticType(rawValue: $0) } ?? .standard
        }
    }

#endif
