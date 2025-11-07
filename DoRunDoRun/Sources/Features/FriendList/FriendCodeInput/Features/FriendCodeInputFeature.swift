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

        var code: String = ""
        var isButtonEnabled: Bool { code.count == 8 }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case toast(ToastFeature.Action)
        
        case codeChanged(String)
        case submitButtonTapped
        case submitSuccess(FriendCode)

        case backButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        
        Reduce { state, action in
            switch action {
                
            case let .codeChanged(text):
                state.code = text
                return .none
                
            case .submitButtonTapped:
                guard state.isButtonEnabled else { return .none }
                return .run { [code = state.code] send in
                    do {
                        let result = try await friendCodeUseCase.execute(code)
                        await send(.submitSuccess(result))
                    } catch {
                        if let apiError = error as? APIError {
                            print(apiError.userMessage)
                        } else {
                            print(APIError.unknown.userMessage)
                        }
                    }
                }
                
            case let .submitSuccess(result):
                print(result.nickname)
                return .none
                
            default:
                return .none
            }
        }
    }
}
