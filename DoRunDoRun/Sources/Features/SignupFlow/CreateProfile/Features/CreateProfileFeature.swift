//
//  CreateProfileFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import UIKit

import ComposableArchitecture

@Reducer
struct CreateProfileFeature {
    @Dependency(\.authSignupUseCase) var signupUseCase

    @ObservableState
    struct State: Equatable {
        var toast = ToastFeature.State()
        var profileImage: UIImage? = nil
        var nickname: String = ""
        var isNicknameValid: Bool {
            nickname.count >= 2 && nickname.count <= 8
        }
        
        // 이전 화면에서 전달받는 값들
        var verifiedPhoneNumber: String = ""
        var marketingConsentAt: Date? = nil
        var locationConsentAt: Date = .now
        var personalConsentAt: Date = .now
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toast(ToastFeature.Action)

        // 내부 동작
        case profileImageButtonTapped
        case imagePicked(UIImage)

        // 버튼 액션
        case bottomButtonTapped
        case signupCompletedSuccess(SignupResult)
        case signupCompletedFailure
        
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
                
                return .run { [state] send in
                    do {
                        let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""

                        let result = try await signupUseCase.execute(
                            phoneNumber: state.verifiedPhoneNumber,
                            nickname: state.nickname,
                            marketingConsentAt: state.marketingConsentAt,
                            locationConsentAt: state.locationConsentAt,
                            personalConsentAt: state.personalConsentAt,
                            deviceToken: fcmToken,
                            profileImage: state.profileImage
                        )
                        await send(.signupCompletedSuccess(result))
                    } catch {
                        await send(.signupCompletedFailure)
                    }
                }

            case let .signupCompletedSuccess(result):
                TokenManager.shared.accessToken = result.token.accessToken
                TokenManager.shared.refreshToken = result.token.refreshToken
                return .send(.completed)

            case .signupCompletedFailure:
                return .send(.toast(.show("회원가입 실패")))

            default:
                return .none
            }
        }
    }
}
