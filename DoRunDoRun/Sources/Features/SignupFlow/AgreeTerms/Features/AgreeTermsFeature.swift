//
//  AgreeTermsFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import ComposableArchitecture
import Foundation

enum AgreementType {
    case signUp
    case findAccount
}

@Reducer
struct AgreeTermsFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var web: AgreeTermsWebFeature.State?
        
        var agreeTermsList: AgreeTermsListFeature.State
        var type: AgreementType
        var isEssentialAgreed: Bool {
            agreeTermsList.isEssentialAgreed
        }

        init(type: AgreementType) {
            self.type = type

            switch type {
            case .signUp:
                self.agreeTermsList = AgreeTermsListFeature.State(
                    agreeTermsRows: [
                        .init(id: 0, title: "[필수] 위치기반 정보 수집 동의", isEssential: true, url: "https://depromeet.notion.site/2aa45b4338b380dfa003f2dda9a02d2c"),
                        .init(id: 1, title: "[필수] 개인정보 수집/이용 동의", isEssential: true, url: "https://depromeet.notion.site/29645b4338b380658ea4d47294188129"),
                        .init(id: 2, title: "[선택] 마케팅 정보 수신 동의", isEssential: false, url: "https://depromeet.notion.site/2aa45b4338b3802db3b4cd5a6e0979fb")
                    ]
                )

            case .findAccount:
                self.agreeTermsList = AgreeTermsListFeature.State(
                    agreeTermsRows: [
                        .init(id: 0, title: "[필수] 서비스 이용약관 동의", isEssential: true, url: ""),
                        .init(id: 1, title: "[필수] 개인정보 수집/이용 동의", isEssential: true, url: ""),
                        .init(id: 2, title: "[필수] 고유식별정보처리 동의", isEssential: true, url: ""),
                        .init(id: 3, title: "[필수] 통신사 이용약관 동의", isEssential: true, url: ""),
                    ]
                )
            }
        }
    }

    enum Action: Equatable {
        case openWebView(String)
        case web(PresentationAction<AgreeTermsWebFeature.Action>)
        
        // 하위 피처
        case agreeTermsList(AgreeTermsListFeature.Action)
        
        // 내부 동작
        case bottomButtonTapped
        
        // 상위 피처에서 처리
        case completed
        case dismissRequested
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.agreeTermsList, action: \.agreeTermsList) {
            AgreeTermsListFeature()
        }

        Reduce { state, action in
            switch action {
                
            case let .agreeTermsList(.delegate(.openWebView(url))):
                return .send(.openWebView(url))

            case let .openWebView(url):
                state.web = .init(url: URL(string: url))
                return .none
                
            case .web(.presented(.backButtonTapped)):
                state.web = nil
                return .none

            case .bottomButtonTapped:
                guard state.isEssentialAgreed else { return .none }
                return .send(.completed)

            default:
                return .none
            }
        }
        .ifLet(\.$web, action: \.web) {
            AgreeTermsWebFeature()
        }

    }
}
