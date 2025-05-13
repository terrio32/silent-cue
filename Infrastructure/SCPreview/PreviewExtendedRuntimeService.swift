#if DEBUG

    import Dependencies
    import Foundation
    import SCProtocol
    import WatchKit

    public class PreviewExtendedRuntimeService: ExtendedRuntimeServiceProtocol {
        public let completionEvents: AsyncStream<Void> = AsyncStream { _ in }
        private var sessionState: WKExtendedRuntimeSessionState = .notStarted

        public init() {}

        public func startSession() async -> Bool {
            // プレビューでは常に成功したと仮定、または特定の状態をシミュレート
            print("PreviewExtendedRuntimeService: Starting session (simulating success).")
            sessionState = .running
            return true
        }

        public func startSession(duration _: TimeInterval, targetEndTime _: Date?) {
            // 必要に応じてレガシー/代替シグネチャを処理
            print("PreviewExtendedRuntimeService: Legacy startSession(duration:targetEndTime:) called.")
            Task { let _ = await startSession() } // 非同期メソッド経由での開始をシミュレート
        }

        public func invalidateSession() {
            print("PreviewExtendedRuntimeService: Invalidating session.")
            sessionState = .invalid
            // プレビューテストで必要な場合に完了イベントを発生させる可能性がある
        }

        public func stopSession() {
            invalidateSession()
        }

        public func getSessionState() -> Int {
            print("PreviewExtendedRuntimeService: Getting session state: \(sessionState).")
            return sessionState.rawValue
        }
    }

#endif
