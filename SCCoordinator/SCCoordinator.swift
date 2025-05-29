import ComposableArchitecture
import SwiftUI

public struct SCCoordinator: Reducer {
    public struct State: Equatable {
        @Equatable var path = NavigationPath()
    }
    
    public enum Action {
        case navigationPathChanged(NavigationPath)
        case push(AnyHashable)
        case pop
        case popToRoot
        case popTo(AnyHashable)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .navigationPathChanged(let path):
                state.path = path
                return .none
                
            case .push(let view):
                state.path.append(view)
                return .none
                
            case .pop:
                if !state.path.isEmpty {
                    state.path.removeLast()
                }
                return .none
                
            case .popToRoot:
                state.path = NavigationPath()
                return .none
                
            case .popTo(let view):
                if let index = state.path.firstIndex(of: view) {
                    state.path.removeLast(state.path.count - index - 1)
                }
                return .none
            }
        }
    }
}