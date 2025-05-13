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
            sessionState = .running
            return true
        }

        public func startSession(duration _: TimeInterval, targetEndTime _: Date?) {
            Task { let _ = await startSession() }
        }

        public func invalidateSession() {
            sessionState = .invalid
        }

        public func stopSession() {
            invalidateSession()
        }

        public func getSessionState() -> Int {
            return sessionState.rawValue
        }
    }

#endif
