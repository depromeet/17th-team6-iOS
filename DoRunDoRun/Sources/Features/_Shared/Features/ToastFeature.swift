//
//  ToastFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

import ComposableArchitecture

@Reducer
struct ToastFeature {
    @ObservableState
    struct State: Equatable {
        var message = ""
        var isVisible = false
    }

    enum Action: Equatable {
        case show(String)
        case hide
    }

    enum CancelID { case toast }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .show(message):
                state.message = message
                state.isVisible = true

                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hide, animation: .easeInOut(duration: 0.3))
                }
                .cancellable(id: CancelID.toast, cancelInFlight: true)

            case .hide:
                state.isVisible = false
                return .none
            }
        }
    }
}
