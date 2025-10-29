//
//  RunningRecordDetailFeature.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/29/25.
//

import ComposableArchitecture

@Reducer
struct RunningRecordDetailFeature {
    @ObservableState
    struct State: Equatable {}
    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
