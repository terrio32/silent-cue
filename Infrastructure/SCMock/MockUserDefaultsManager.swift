import Combine
import Dependencies
import Foundation
import SCProtocol
import SCShared

public class MockUserDefaultsManager: UserDefaultsServiceProtocol {
    // UserDefaultsの代わりとなるインメモリ辞書
    public var storage: [String: Any] = [:]

    // 検証用の呼び出し追跡
    public var saveHapticTypeCallCount = 0
    public var loadHapticTypeCallCount = 0
    public var setCallCount = 0
    public var objectCallCount = 0
    public var boolCallCount = 0
    public var removeCallCount = 0
    public var removeAllCallCount = 0

    public init() {}

    public func set(_ value: Any?, forKey defaultName: UserDefaultsKeys) {
        setCallCount += 1
        let key = defaultName.rawValue
        if let value {
            storage[key] = value
        } else {
            storage.removeValue(forKey: key)
        }
    }

    public func object(forKey defaultName: UserDefaultsKeys) -> Any? {
        objectCallCount += 1
        let key = defaultName.rawValue
        let value = storage[key]
        return value
    }

    public func bool(forKey defaultName: UserDefaultsKeys) -> Bool? {
        boolCallCount += 1
        let key = defaultName.rawValue
        let value = storage[key] as? Bool
        return value
    }

    public func remove(forKey defaultName: UserDefaultsKeys) {
        removeCallCount += 1
        let key = defaultName.rawValue
        storage.removeValue(forKey: key)
    }

    public func removeAll() {
        removeAllCallCount += 1
        storage.removeAll()
    }

    // --- プロトコルメソッド ---

    public func saveHapticType(_ type: HapticType) {
        saveHapticTypeCallCount += 1
        let key = UserDefaultsKeys.hapticType.rawValue
        storage[key] = type.rawValue
    }

    public func loadHapticType() -> HapticType {
        loadHapticTypeCallCount += 1
        let key = UserDefaultsKeys.hapticType.rawValue
        let value = storage[key] as? String ?? HapticType.standard.rawValue
        let type = HapticType(rawValue: value) ?? .standard
        return type
    }

    // --- モック固有のメソッド ---
    public func getAllValues() -> [String: Any] {
        storage
    }

    // テスト用のリセット関数
    public func reset() {
        storage = [:]
        saveHapticTypeCallCount = 0
        loadHapticTypeCallCount = 0
        setCallCount = 0
        objectCallCount = 0
        boolCallCount = 0
        removeCallCount = 0
        removeAllCallCount = 0
    }
}
