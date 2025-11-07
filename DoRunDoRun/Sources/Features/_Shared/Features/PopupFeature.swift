//
//  PopupFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

import ComposableArchitecture

@Reducer
struct PopupFeature {
    @ObservableState
    struct State: Equatable {
        enum PopupAction: Equatable {
            case none
            case signup
            case findAccount
            case marketingOff
            case logout
            case withdraw
            case deleteFriend(Int)
        }
        var action: PopupAction = .none
        var isVisible = false
        var title = ""
        var message: String? = nil
        var actionTitle = ""
        var cancelTitle = ""
    }

    enum Action: Equatable {
        case show(
            action: State.PopupAction,
            title: String,
            message: String? = nil,
            actionTitle: String,
            cancelTitle: String
        )
        case hide
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .show(popupAction, title, message, actionTitle, cancelTitle):
                state.action = popupAction
                state.isVisible = true
                state.title = title
                state.message = message
                state.actionTitle = actionTitle
                state.cancelTitle = cancelTitle
                return .none

            case .hide:
                state.isVisible = false
                return .none
            }
        }
    }
}

