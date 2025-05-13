import Dependencies
import Foundation
import SCProtocol
import WatchKit

public class LiveHapticsService: HapticsServiceProtocol {
    public init() {}

    public func play(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}
