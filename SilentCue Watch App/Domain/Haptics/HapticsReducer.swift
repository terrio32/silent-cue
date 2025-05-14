import ComposableArchitecture
import Dependencies
import Foundation
import WatchKit

struct HapticsReducer: Reducer {
    typealias State = HapticsState
    typealias Action = HapticsAction

    private enum CancelID {
        case haptic
        case hapticPreviewTimer
        case hapticPreviewTimeout
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.date) var date
    @Dependency(\.hapticsService) var hapticsService

    var body: some ReducerOf<Self> {
        Reduce { state, action in

            switch action {
                case let .startHaptic(type):
                    var effect = Effect<Action>.none
                    if state.isActive {
                        effect = .cancel(id: CancelID.haptic)
                    }
                    state.isActive = true
                    state.hapticType = type

                    return .merge(
                        effect,
                        .run { [type] _ in
                            hapticsService.play(type.wkHapticType)
                        }
                        .cancellable(id: CancelID.haptic)
                    )

                case .stopHaptic:
                    state.isActive = false
                    return .cancel(id: CancelID.haptic)

                case let .startPreview(hapticType):
                    state.isPreviewingHaptic = true
                    state.previewTargetHapticType = hapticType

                    return .merge(
                        .run { _ in hapticsService.play(hapticType.wkHapticType) },
                        .run { [hapticType] send in
                            for await _ in clock.timer(interval: .seconds(hapticType.interval)) {
                                await send(HapticsAction.previewTick)
                            }
                        }
                        .cancellable(id: CancelID.hapticPreviewTimer, cancelInFlight: true),
                        .run { send in
                            try await clock.sleep(for: .seconds(3))
                            await send(HapticsAction.stopPreview)
                        }
                        .cancellable(id: CancelID.hapticPreviewTimeout, cancelInFlight: true)
                    )

                case .previewTick:
                    guard state.isPreviewingHaptic, let targetType = state.previewTargetHapticType else {
                        return .none
                    }
                    hapticsService.play(targetType.wkHapticType)
                    return .none

                case .stopPreview:
                    guard state.isPreviewingHaptic else { return .none }
                    state.isPreviewingHaptic = false
                    state.previewTargetHapticType = nil
                    return .merge(
                        .cancel(id: CancelID.hapticPreviewTimer),
                        .cancel(id: CancelID.hapticPreviewTimeout)
                    )

                case let .updateHapticSettings(type):
                    state.hapticType = type
                    return .none
            }
        }
    }
}
