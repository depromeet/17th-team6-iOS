//
//  FriendCodeInputFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FriendCodeInputFeature {
    @Dependency(\.friendCodeUseCase) var friendCodeUseCase
    
    @ObservableState
    struct State: Equatable {
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()

        var code: String = ""
        var isButtonEnabled: Bool { code.count == 8 }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case toast(ToastFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        case codeChanged(String)
        case submitButtonTapped
        case submitSuccess(FriendCode)
        case submitFailure(APIError)

        case backButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }
        
        Reduce { state, action in
            switch action {
                
            case let .codeChanged(text):
                state.code = text
                return .none
                
            case .submitButtonTapped:
                guard state.isButtonEnabled else {
                    return .send(.toast(.show("코드가 올바르지 않아요. 다시 입력해주세요.")))
                }

                return .run { [code = state.code] send in
                    do {
                        let result = try await friendCodeUseCase.execute(code)
                        await send(.submitSuccess(result))
                    } catch {
                        if let apiError = error as? APIError {
                            await send(.submitFailure(apiError))
                        } else {
                            await send(.submitFailure(.unknown))
                        }
                    }
                }
                
            case let .submitSuccess(result):
                print(result.nickname)
                return .none
                
            case let .submitFailure(apiError):
                print("🔥 API ERROR:", apiError)
                switch apiError {
                case .networkError:
                    return .send(.networkErrorPopup(.show))
                case .notFound:
                    return .send(.toast(.show("존재하지 않는 코드예요. 다시 입력해주세요.")))
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
                return .send(.submitButtonTapped)
                
            default:
                return .none
            }
        }
    }
}
