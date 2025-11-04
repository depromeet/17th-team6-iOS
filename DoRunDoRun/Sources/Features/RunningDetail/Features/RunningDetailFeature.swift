//
//  RunningDetailFeature.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/29/25.
//

import ComposableArchitecture

@Reducer
struct RunningDetailFeature {
    @ObservableState
    struct State: Equatable {
        var detail: RunningDetailViewState
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case backButtonTapped
        case recordVerificationButtonTapped
        case getRouteImageData
        
        case sendRunningData
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                // TODO: 화면 전환 로직 추가
                return .none
                
            case .recordVerificationButtonTapped:
                // TODO: 화면 전환 로직 추가
                return .none
                
            case .getRouteImageData:
                // 이미지 들어온 거 확인
                return .send(.sendRunningData)
                
            case .sendRunningData:
                // 이미지 데이터 들어오면 최종 데이터 서버로 전달
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}
