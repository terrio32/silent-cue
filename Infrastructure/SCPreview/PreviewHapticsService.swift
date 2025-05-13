#if DEBUG

    import Dependencies
    import Foundation
    import SCProtocol
    import WatchKit

    // Preview用のHapticsService実装
    public class PreviewHapticsService: HapticsServiceProtocol {
        public init() {}

        // プロトコルに合わせてシグネチャを変更
        public func play(_ type: WKHapticType) {
            // プレビューでは実際の触覚フィードバックを再生せず、ログ出力で代替
            let typeName = hapticTypeName(type)
            print("PreviewHapticsService: Playing haptic type: \(typeName) (Enum: \(type))")
        }

        // WKHapticType から可読な名前を取得するヘルパー (任意)
        private func hapticTypeName(_ type: WKHapticType) -> String {
            switch type {
                // HapticType enum からマップされたケースのみ保持
                case .success: return "Success"
                case .retry: return "Retry"
                case .directionUp: return "DirectionUp"
                default:
                    return "Unknown (\(type.rawValue))"
            }
        }
    }

#endif
