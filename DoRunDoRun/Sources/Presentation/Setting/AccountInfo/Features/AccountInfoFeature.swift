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
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
    }

    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case fetchProfileSuccess(UserProfile)
        case fetchProfileFailure(APIError)
        case backButtonTapped
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }
        
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
                            await send(.fetchProfileFailure(apiError))
                        } else {
                            await send(.fetchProfileFailure(.unknown))
                        }
                    }
                }

            case let .fetchProfileSuccess(result):
                state.isLoading = false
                let viewState = UserProfileViewStateMapper.map(from: result)
                state.profile = viewState
                return .none
                
            case let .fetchProfileFailure(apiError):
                state.isLoading = false
                switch apiError {
                case .networkError:
                    return .send(.networkErrorPopup(.show))
                case .notFound:
                    return .send(.serverError(.show(.notFound)))
                case .internalServer:
                    return .send(.serverError(.show(.internalServer)))
                case .badGateway:
                    return .send(.serverError(.show(.badGateway)))
                default:
                    print(apiError.userMessage)
                    return .none
                }
                
            case .networkErrorPopup(.retryButtonTapped),
                    .serverError(.retryButtonTapped):
                return .send(.onAppear)

            default:
                return .none
            }
        }
    }
}
