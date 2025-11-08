//
//  SettingFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingFeature {
    @Dependency(\.authLogoutUseCase) var logoutUseCase
    @Dependency(\.authWithdrawUseCase) var withdrawUseCase
    
    @ObservableState
    struct State: Equatable {
        var toast = ToastFeature.State()
        var popup = PopupFeature.State()
        var appVersion: String = "3.13.0"
        
        @Presents var editProfile: EditProfileFeature.State?
        @Presents var accountInfo: AccountInfoFeature.State?
        @Presents var pushNotificationSetting: PushNotificationSettingFeature.State?
    }

    enum Action: Equatable {
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        case onAppear
        
        case editProfileTapped
        case editProfile(PresentationAction<EditProfileFeature.Action>)
        case accountInfoTapped
        case accountInfo(PresentationAction<AccountInfoFeature.Action>)
        case pushNotificationSettingTapped
        case pushNotificationSetting(PresentationAction<PushNotificationSettingFeature.Action>)

        case privacyPolicyTapped
        case termsTapped
        case logoutTapped
        case withdrawTapped
        case popupConfirmTapped
        
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }

        Reduce { state, action in
            switch action {

            case .onAppear:
                return .none

            case .editProfileTapped:
                state.editProfile = EditProfileFeature.State()
                return .none
                
            case .editProfile(.presented(.completed)):
                state.editProfile = nil
                return .none
                
            case .editProfile(.presented(.backButtonTapped)):
                state.editProfile = nil
                return .none

            case .accountInfoTapped:
                state.accountInfo = AccountInfoFeature.State()
                return .none
                
            case .accountInfo(.presented(.backButtonTapped)):
                state.accountInfo = nil
                return .none

            case .pushNotificationSettingTapped:
                state.pushNotificationSetting = PushNotificationSettingFeature.State()
                return .none
                
            case .pushNotificationSetting(.presented(.backButtonTapped)):
                state.pushNotificationSetting = nil
                return .none

            case .privacyPolicyTapped:
                print("개인정보처리방침 탭")
                return .none

            case .termsTapped:
                print("약관 및 정책 탭")
                return .none

            case .logoutTapped:
                return .send(.popup(.show(
                    action: .logout,
                    title: "정말 계정을 로그아웃할까요?",
                    message: "재로그인할 수 있어요.",
                    actionTitle: "로그아웃",
                    cancelTitle: "닫기"
                )))

            // MARK: - 탈퇴 팝업
            case .withdrawTapped:
                return .send(.popup(.show(
                    action: .withdraw,
                    title: "정말 계정을 탈퇴할까요?",
                    message: "탈퇴하면 되돌릴 수 없어요.",
                    actionTitle: "탈퇴하기",
                    cancelTitle: "닫기"
                )))

            // MARK: - 팝업 액션
            case .popupConfirmTapped:
                switch state.popup.action {
                case .logout:
                    return .run { send in
                        do {
                            try await logoutUseCase.execute()
                            FCMTokenManager.shared.clear()
                            TokenManager.shared.clear()
                            UserManager.shared.clear()
                        } catch {
                            //TODO: Error Handling
                        }
                    }

                case .withdraw:
                    return .run { send in
                        do {
                            try await withdrawUseCase.execute()
                            FCMTokenManager.shared.clear()
                            TokenManager.shared.clear()
                            UserManager.shared.clear()
                        } catch {
                            //TODO: Error Handling
                        }
                    }

                default:
                    return .none
                }

            default:
                return .none
            }
        }
        .ifLet(\.$editProfile, action: \.editProfile) {
            EditProfileFeature()
        }
        .ifLet(\.$accountInfo, action: \.accountInfo) {
            AccountInfoFeature()
        }
        .ifLet(\.$pushNotificationSetting, action: \.pushNotificationSetting) {
            PushNotificationSettingFeature()
        }
    }
}
