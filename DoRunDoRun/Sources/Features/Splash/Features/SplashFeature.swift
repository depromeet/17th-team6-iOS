//
//  SplashFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SplashFeature {
    @ObservableState
    struct State: Equatable {
        var isFinished = false
    }
    
    enum Action: Equatable {
        case onAppear
        case splashTimeoutEnded
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 1초 후 Splash 종료
                return .run { send in
                    try await Task.sleep(for: .seconds(1))
                    await send(.splashTimeoutEnded)
                }
                
            case .splashTimeoutEnded:
                state.isFinished = true
                return .none
            }
        }
    }
}
