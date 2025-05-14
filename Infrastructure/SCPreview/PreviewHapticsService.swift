#if DEBUG

    import Dependencies
    import Foundation
    import SCProtocol
    import WatchKit

    public class PreviewHapticsService: HapticsServiceProtocol {
        public init() {}

        public func play(_: WKHapticType) {}
    }

#endif
