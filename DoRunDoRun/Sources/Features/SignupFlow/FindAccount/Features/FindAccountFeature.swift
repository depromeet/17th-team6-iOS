//
//  FindAccountView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct FindAccountFeature {
    @ObservableState
    struct State: Equatable {
        var url: URL? = URL(string: "https://www.depromeet.com/") // 웹뷰 URL
    }

    enum Action: Equatable {
        case backButtonTapped
        case webViewFinished // 필요 시
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                // 상위 피처에서 네비게이션 처리
                return .none

            case .webViewFinished:
                // 필요하면 웹뷰 이벤트 처리
                return .none
            }
        }
    }
}
