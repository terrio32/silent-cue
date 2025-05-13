import Dependencies
import Foundation
import SCProtocol
import WatchKit

public class MockHapticsService: HapticsServiceProtocol {
    // 検証のために再生されたハプティクスタイプを追跡
    public var playedHapticTypes: [WKHapticType] = []
    public var playCallCount = 0
    public var lastPlayedHapticType: WKHapticType?

    public init() {}

    public func play(_ type: WKHapticType) {
        playCallCount += 1
        playedHapticTypes.append(type)
        lastPlayedHapticType = type
        print("MockHapticsService: Playing haptic type: \(type)")
    }

    // テスト用にリセットするための関数
    public func reset() {
        playedHapticTypes.removeAll()
        playCallCount = 0
        lastPlayedHapticType = nil
    }
}
