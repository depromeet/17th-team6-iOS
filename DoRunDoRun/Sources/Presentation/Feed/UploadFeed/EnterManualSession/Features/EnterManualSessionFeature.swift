//
//  EnterManualSessionFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/10/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EnterManualSessionFeature {

    // MARK: - State

    @ObservableState
    struct State: Equatable {

        var startTime: Date? = nil
        var duration: DateComponents? = nil
        var distanceWhole: Int? = nil
        var distanceDecimal: Int? = nil
        var paceMinute: Int? = nil
        var paceSecond: Int? = nil
        var cadence: String = ""

        var isRequiredFieldsFilled: Bool {
            startTime != nil &&
            duration != nil &&
            distanceWhole != nil &&
            distanceDecimal != nil
        }
    }

    // MARK: - Action

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case addButtonTapped
        case backButtonTapped
    }

    // MARK: - Reducer

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
                
            case .addButtonTapped:
                return .none
                
            case .backButtonTapped:
                return .none

            case .binding:
                return .none
            }
        }
    }
}
