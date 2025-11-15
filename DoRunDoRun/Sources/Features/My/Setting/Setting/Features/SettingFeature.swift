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
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()

        var appVersion: String = "1.0.1"
        
        @Presents var editProfile: EditProfileFeature.State?
        @Presents var accountInfo: AccountInfoFeature.State?
        @Presents var pushNotificationSetting: PushNotificationSettingFeature.State?
        
        enum FailedRequestType: Equatable {
            case logout
            case withdraw
        }
        var lastFailedRequest: FailedRequestType? = nil
        
        @Presents var web: SettingWebFeature.State?
    }

    enum Action: Equatable {
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
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
        case logoutFailure(APIError)
        case withdrawFailure(APIError)
        
        case backButtonTapped

        enum Delegate: Equatable {
            case logoutCompleted
            case withdrawCompleted
        }
        case delegate(Delegate)
        
        case web(PresentationAction<SettingWebFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            case .onAppear:
                return .none

            case .editProfileTapped:
                let currentNickname = UserManager.shared.nickname
                let currentImageURL = UserManager.shared.profileImageURL
                state.editProfile = EditProfileFeature.State(
                    profileImageURL: currentImageURL,
                    nickname: currentNickname
                )
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
                state.web = .init(
                    urlString: "https://depromeet.notion.site/29645b4338b380658ea4d47294188129",
                    title: "개인정보처리방침"
                )
                return .none

            case .termsTapped:
                state.web = .init(
                    urlString: "https://depromeet.notion.site/2ab45b4338b380728db8de7e6b152490",
                    title: "약관 및 정책"
                )
                return .none
                
            case .web(.presented(.backButtonTapped)):
                state.web = nil
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
                    state.lastFailedRequest = .logout
                    return performLogout()
                    
                case .withdraw:
                    state.lastFailedRequest = .withdraw
                    return performWithdraw()
                    
                default:
                    return .none
                }
            
            // MARK: - 로그아웃, 탈퇴 에러 핸들링
            case let .logoutFailure(apiError),
                 let .withdrawFailure(apiError):
                return handleAPIError(apiError)
                
            // MARK: - 재시도
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                guard let failed = state.lastFailedRequest else { return .none }

                switch failed {
                case .logout:
                    return performLogout()
                case .withdraw:
                    return performWithdraw()
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
        .ifLet(\.$web, action: \.web) {
            SettingWebFeature()
        }
    }
    
    private func performLogout() -> Effect<Action> {
        .run { send in
            do {
                try await logoutUseCase.execute()
                FCMTokenManager.shared.clear()
                TokenManager.shared.clear()
                UserManager.shared.clear()
                await send(.delegate(.logoutCompleted))
            } catch {
                await send(.logoutFailure(error as? APIError ?? .unknown))
            }
        }
    }

    private func performWithdraw() -> Effect<Action> {
        .run { send in
            do {
                try await withdrawUseCase.execute()
                FCMTokenManager.shared.clear()
                TokenManager.shared.clear()
                UserManager.shared.clear()
                await send(.delegate(.withdrawCompleted))
            } catch {
                await send(.withdrawFailure(error as? APIError ?? .unknown))
            }
        }
    }
    
    private func handleAPIError(_ apiError: APIError) -> Effect<Action> {
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
    }
}
