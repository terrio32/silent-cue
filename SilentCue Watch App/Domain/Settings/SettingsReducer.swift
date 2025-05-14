import ComposableArchitecture
import Foundation
import SCProtocol
import SCShared
import WatchKit

struct SettingsReducer: Reducer {
    typealias State = SettingsState
    typealias Action = SettingsAction

    private enum CancelID {
        case saveSettings
    }

    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.hapticsService) var hapticsService
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in

            switch action {
                case .loadSettings:
                    return .run { send in
                        let typeRaw = userDefaultsService.object(forKey: UserDefaultsKeys.hapticType) as? String
                        let hapticType = typeRaw.flatMap { HapticType(rawValue: $0) } ?? HapticType.standard
                        await send(.settingsLoaded(hapticType: hapticType))
                    }

                case let .settingsLoaded(hapticType):
                    state.selectedHapticType = hapticType
                    state.isSettingsLoaded = true
                    return .none

                case let .selectHapticType(type):
                    state.selectedHapticType = type
                    return .send(.saveSettings)

                case .saveSettings:
                    return .run { [selectedType = state.selectedHapticType] _ in
                        userDefaultsService.set(selectedType.rawValue, forKey: .hapticType)
                    }
                    .cancellable(id: CancelID.saveSettings, cancelInFlight: true)

                case .backButtonTapped:
                    return .none
            }
        }
    }
}
