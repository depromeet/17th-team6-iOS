//
//  AccountInfoFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import ComposableArchitecture

@Reducer
struct AccountInfoFeature {
    // MARK: - Dependency
    @Dependency(\.userProfileUseCase) var userProfileUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var profile: UserProfileViewState?
        var isLoading: Bool = false
    }

    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case fetchProfileSuccess(UserProfile)
        case backButtonTapped
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .run { send in
                    do {
                        let result = try await userProfileUseCase.execute()
                        await send(.fetchProfileSuccess(result))
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.userMessage)
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }

            case let .fetchProfileSuccess(result):
                state.isLoading = false
                let viewState = UserProfileViewStateMapper.map(from: result)
                state.profile = viewState
                return .none

            default:
                return .none
            }
        }
    }
}
