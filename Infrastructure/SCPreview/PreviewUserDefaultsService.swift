#if DEBUG

    import Dependencies
    import Foundation
    import SCProtocol
    import SCShared

    public class PreviewUserDefaultsService: UserDefaultsServiceProtocol {
        // データを保持するためのインメモリ辞書
        private var storage: [String: Any] = [:]

        public init() {
            // デフォルト値で初期化
            storage = [
                UserDefaultsKeys.hapticType.rawValue: HapticType.standard.rawValue,
                UserDefaultsKeys.isFirstLaunch.rawValue: true,
            ]
            print("💾 [プレビューUserDefaults] 初期化完了: \(storage)")
        }

        /// 指定されたキーに値を設定
        public func set(_ value: Any?, forKey defaultName: UserDefaultsKeys) {
            let key = defaultName.rawValue
            print("💾 [プレビューUserDefaults] セット \(key): \(String(describing: value))")
            if let value {
                storage[key] = value
            } else {
                storage.removeValue(forKey: key)
            }
        }

        /// 指定されたキーに関連付けられたオブジェクトを返す
        public func object(forKey defaultName: UserDefaultsKeys) -> Any? {
            let key = defaultName.rawValue
            let value = storage[key]
            print("💾 [プレビューUserDefaults] ゲット \(key): \(String(describing: value))")
            return value
        }

        /// 指定されたキーに関連付けられた真偽値を返す
        public func bool(forKey defaultName: UserDefaultsKeys) -> Bool? {
            let key = defaultName.rawValue
            let value = storage[key] as? Bool
            print("💾 [プレビューUserDefaults] ゲットBool \(key): \(value.map { String(describing: $0) } ?? "nil")")
            return value
        }

        /// 指定されたキーの値を削除
        public func remove(forKey defaultName: UserDefaultsKeys) {
            let key = defaultName.rawValue
            print("💾 [プレビューUserDefaults] 削除 \(key)")
            storage.removeValue(forKey: key)
        }

        /// すべての値を削除
        public func removeAll() {
            print("💾 [プレビューUserDefaults] 全削除")
            storage.removeAll()
        }

        public func saveHapticType(_ type: HapticType) {
            let key = UserDefaultsKeys.hapticType.rawValue
            storage[key] = type.rawValue
            print("💾 [プレビューUserDefaults] 保存 hapticType: \(type.rawValue)")
        }

        public func loadHapticType() -> HapticType {
            let key = UserDefaultsKeys.hapticType.rawValue
            let value = storage[key] as? String ?? HapticType.standard.rawValue
            let type = HapticType(rawValue: value) ?? .standard
            print("💾 [プレビューUserDefaults] 読込 hapticType: \(type.rawValue)")
            return type
        }

        // --- プレビュー/テスト固有のメソッド ---

        /// 特定の初期値を設定するために使用 (UIテストで便利)
        public func setupInitialValues(_ values: [UserDefaultsKeys: Any]) {
            print("💾 [プレビューUserDefaults] 初期値設定: \(values.mapValues { String(describing: $0) })")
            removeAll() // クリーンな状態から開始
            for (key, value) in values {
                set(value, forKey: key) // 公開されている set メソッドを使用
            }
        }
    }

#endif
