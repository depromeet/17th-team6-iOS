//
//  CheckAccountFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import ComposableArchitecture

// 서버 연동 이후 변경 or 삭제
struct AccountInfo: Equatable {
    var profileImage: String?
    var name: String
    var phoneNumber: String
    var joinDate: String
}

@Reducer
struct CheckAccountFeature {
    @Dependency(\.continuousClock) var clock

    @ObservableState
    struct State: Equatable {
        enum Status: Equatable { case loading, loaded, failed(String) }
        var status: Status = .loading
        var accountInfo: AccountInfo? = nil
    }

    enum Action: Equatable {
        // 내부 동작
        case onAppear
        case fetchCompletedSuccess(AccountInfo?)
        case fetchCompletedFailure
        
        // 상위 피처에서 처리
        case loginButtonTapped
        case signupButtonTapped
        case backButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.status = .loading

                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.fetchCompletedSuccess(.init(
                        profileImage: nil,
                        name: "비락식혜",
                        phoneNumber: "010-1234-5678",
                        joinDate: "2025.10.17 가입"
                    )))
                }

            case let .fetchCompletedSuccess(info):
                if let info {
                    state.status = .loaded
                    state.accountInfo = info
                } else {
                    state.status = .failed("가입된 계정을 찾을 수 없습니다.")
                }
                return .none

            case .fetchCompletedFailure:
                state.status = .failed("가입 이력을 확인하는 중 오류가 발생했습니다.")
                return .none
                
            default:
                return .none
            }
        }
    }

}
