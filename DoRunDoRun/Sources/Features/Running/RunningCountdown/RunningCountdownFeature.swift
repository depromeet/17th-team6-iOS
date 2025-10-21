//
//  RunningCountdownFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import ComposableArchitecture

@Reducer
struct RunningCountdownFeature {
    @ObservableState
    struct State: Equatable {
        /// 현재 카운트 숫자 (3 → 2 → 1 → nil)
        var count: Int? = nil
    }

    enum Action: Equatable {
        case onAppear                 // 카운트다운 시작 트리거
        case updateCountdown(Int?)    // 숫자 업데이트
        case countdownCompleted       // 카운트다운 완료
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                // “잠시 후…” 1초 대기 후 3→2→1 카운트다운
                return .run { send in
                    try await Task.sleep(for: .seconds(1)) // “잠시 후” 1초
                    for i in stride(from: 3, through: 1, by: -1) {
                        await send(.updateCountdown(i))
                        try await Task.sleep(for: .seconds(1))
                    }
                    await send(.countdownCompleted)
                }

            case let .updateCountdown(value):
                state.count = value
                return .none

            case .countdownCompleted:
                state.count = nil
                // 실제 전환 로직은 상위 Feature(RunningFeature)에서 담당
                return .none
            }
        }
    }
}
