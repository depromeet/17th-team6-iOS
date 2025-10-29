//
//  SelectCarrierFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/25/25.
//

import ComposableArchitecture

@Reducer
struct SelectCarrierFeature {
    @ObservableState
    struct State: Equatable {
        var carriers = ["SKT", "KT", "LG U+", "SKT 알뜰폰", "KT 알뜰폰", "LG U+ 알뜰폰"]
        var selectedCarrier: String = ""
    }

    enum Action: Equatable {
        // 내부 동작
        case carrierTapped(String)
        
        // 상위 피처에서 처리
        case dismissRequested
    }

    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            case .carrierTapped(let carrier):
                state.selectedCarrier = carrier
                return .none
                
            default:
                return .none
            }
        }
    }
}
