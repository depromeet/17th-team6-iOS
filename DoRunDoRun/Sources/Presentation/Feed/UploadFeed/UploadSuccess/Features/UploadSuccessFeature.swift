//
//  UploadSuccessFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 1/9/26.
//

import ComposableArchitecture
import UIKit

@Reducer
struct UploadSuccessFeature {
    @Dependency(\.analyticsTracker) var analytics

    struct State: Equatable {
        var isPresented: Bool = true
    }

    enum Action: Equatable {
        case onAppear

        enum DelegateAction: Equatable {
            case uploadSuccessCompleted
        }
        case delegate(DelegateAction)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                // event
                analytics.track(.screenViewed(.uploadSuccess))
                return .run { send in
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await send(.delegate(.uploadSuccessCompleted))
                }

            case .delegate:
                return .none
            }
        }
    }
}
