//
//  AgreeTermsListFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/25/25.
//

import ComposableArchitecture

@Reducer
struct AgreeTermsListFeature {
    @ObservableState
    struct State: Equatable {
        var agreeTermsRows: IdentifiedArrayOf<AgreeTermsRowFeature.State> = []
        var isAllAgreed = false
        var isEssentialAgreed: Bool {
            agreeTermsRows
                .filter(\.isEssential)
                .allSatisfy(\.isOn)
        }
        
        var isMarketingAgreed: Bool {
            agreeTermsRows.contains { $0.title.contains("마케팅") && $0.isOn }
        }
    }

    enum Action: Equatable {
        // 하위 피처
        case agreeTermsRows(IdentifiedActionOf<AgreeTermsRowFeature>)

        // 내부 동작
        case toggleAllAgreements(Bool)
        case setAllRowsAgreement(Bool)

        enum Delegate: Equatable {
            case openWebView(String)
        }
        case delegate(Delegate)
    }

    private enum CancelID {
        case toggleAll
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .toggleAllAgreements(isOn):
                state.isAllAgreed = isOn
                return .run { send in
                    try await Task.sleep(for: .milliseconds(100))
                    await send(.setAllRowsAgreement(isOn))
                }
                .cancellable(id: CancelID.toggleAll, cancelInFlight: true)

            case let .setAllRowsAgreement(isOn):
                for id in state.agreeTermsRows.ids {
                    state.agreeTermsRows[id: id]?.isOn = isOn
                }
                return .none

            case .agreeTermsRows(.element(id: _, action: .toggle)):
                state.isAllAgreed = state.agreeTermsRows.allSatisfy(\.isOn)
                return .none
                
            case let .agreeTermsRows(.element(id: _, action: .delegate(.openWebView(url)))):
                return .send(.delegate(.openWebView(url)))

            default:
                return .none
            }
        }
        .forEach(\.agreeTermsRows, action: \.agreeTermsRows) {
            AgreeTermsRowFeature()
        }
    }
}
