import Combine
import Dependencies
import Foundation
import SCProtocol
import WatchKit

public class MockExtendedRuntimeService: ExtendedRuntimeServiceProtocol {
    // テスト用制御フラグ
    public var startSessionShouldSucceed: Bool = true
    public var mockSessionState: WKExtendedRuntimeSessionState = .notStarted
    public var shouldYieldCompletionEvent: Bool = false // 完了イベントを発行するかどうか

    // 呼び出し回数追跡用
    public var startSessionCallCount = 0
    public var invalidateSessionCallCount = 0
    public var getSessionStateCallCount = 0
    public var stopSessionCallCount = 0

    // startSession(duration:targetEndTime:) に渡されるパラメータ
    public var lastStartSessionDuration: TimeInterval?
    public var lastStartSessionTargetEndTime: Date?

    // 完了イベント用ストリーム
    private let completionStreamContinuation: AsyncStream<Void>.Continuation
    public let completionEvents: AsyncStream<Void>

    public init() {
        var streamContinuation: AsyncStream<Void>.Continuation?
        completionEvents = AsyncStream { continuation in
            streamContinuation = continuation
        }
        completionStreamContinuation = streamContinuation!
    }

    public func startSession() async -> Bool {
        startSessionCallCount += 1
        if startSessionShouldSucceed {
            mockSessionState = .running
        }
        return startSessionShouldSucceed
    }

    public func startSession(duration: TimeInterval, targetEndTime: Date?) {
        startSessionCallCount += 1
        lastStartSessionDuration = duration
        lastStartSessionTargetEndTime = targetEndTime
    }

    public func invalidateSession() {
        invalidateSessionCallCount += 1
        mockSessionState = .invalid
        if shouldYieldCompletionEvent {
            completionStreamContinuation.yield(())
        }
    }

    public func stopSession() {
        stopSessionCallCount += 1
        invalidateSession()
    }

    public func getSessionState() -> Int {
        getSessionStateCallCount += 1
        return mockSessionState.rawValue
    }

    // テスト用バックグラウンド完了イベントを発行する
    public func triggerCompletion() {
        completionStreamContinuation.yield(())
        completionStreamContinuation.finish() // ストリームを終了させる
    }

    // テスト用リセット関数
    public func reset() {
        startSessionShouldSucceed = true
        mockSessionState = .notStarted
        shouldYieldCompletionEvent = false
        startSessionCallCount = 0
        invalidateSessionCallCount = 0
        getSessionStateCallCount = 0
        stopSessionCallCount = 0
        lastStartSessionDuration = nil
        lastStartSessionTargetEndTime = nil
    }
}
