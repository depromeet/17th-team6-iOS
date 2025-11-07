//
//  EditProfileFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import UIKit
import ComposableArchitecture

@Reducer
struct EditProfileFeature {

    @ObservableState
    struct State: Equatable {
        var toast = ToastFeature.State()
        var profileImage: UIImage? = nil
        var nickname: String = ""
        var isNicknameValid: Bool {
            nickname.count >= 2 && nickname.count <= 8
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toast(ToastFeature.Action)

        // 내부 동작
        case profileImageButtonTapped
        case imagePicked(UIImage)

        // 버튼 액션
        case bottomButtonTapped
        
        // 상위 피처에서 처리
        case completed
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.toast, action: \.toast) { ToastFeature() }

        Reduce { state, action in
            switch action {
            case let .imagePicked(image):
                state.profileImage = image
                return .none

            case .bottomButtonTapped:
                guard state.isNicknameValid else {
                    return .send(.toast(.show("2-8자 이내로 닉네임을 입력해주세요.")))
                }
                return .none

            default:
                return .none
            }
        }
    }
}
