//
//  PushNotificationSettingFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PushNotificationSettingFeature {
    @ObservableState
    struct State: Equatable {
        var toast = ToastFeature.State()
        var popup = PopupFeature.State()

        // 푸시 설정 상태
        var isMarketingPushOn: Bool = true
        var isGlobalPushOn: Bool = false
        var marketingAgreementDate: String? = "2025.10.27"

        var detailToggles: [PushDetailItem] = [
            .init(title: "깨우기", description: "친구가 나를 깨울 때 알림을 받습니다.", isOn: false),
            .init(title: "내 게시물 반응", description: "내 게시물에 반응이 달렸을 때 알림을 받습니다.", isOn: false),
            .init(title: "친구 게시물 업로드", description: "친구가 새로운 게시물을 업로드했을 때 알림을 받습니다.", isOn: false),
            .init(title: "인증 마감 시간 알림", description: "러닝 인증 마감 1시간 전에 알림을 받습니다.", isOn: false),
            .init(title: "러닝 진행 알림", description: "일부러 긴 러닝 진행을 알릴 경우 알림을 받습니다.", isOn: false)
        ]
    }

    enum Action: Equatable {
        case toast(ToastFeature.Action)
        case popup(PopupFeature.Action)

        case onAppear
        case toggleMarketingPush(Bool)
        case toggleGlobalPush(Bool)
        case toggleDetailItem(Int, Bool)
        case popupConfirmTapped
        case popupCancelTapped
        
        // 상위 피처에서 처리
        case backButtonTapped
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.popup, action: \.popup) { PopupFeature() }

        Reduce { state, action in
            switch action {

            case .onAppear:
                return .none

            // MARK: - 마케팅 푸시 토글
            case let .toggleMarketingPush(isOn):
                if isOn {
                    state.isMarketingPushOn = true
                    state.marketingAgreementDate = "2025.10.27"
                    return .send(.toast(.show("마케팅 정보 수신 동의")))
                } else {
                    return .send(.popup(.show(
                        action: .marketingOff,
                        title: "마케팅 알림을 끌까요?",
                        message: "유용한 정보나 이벤트 관련 알림을\n받지 못할 수도 있어요.",
                        actionTitle: "끄기",
                        cancelTitle: "알림 유지"
                    )))
                }

            // MARK: - 전체 알림
            case let .toggleGlobalPush(isOn):
                state.isGlobalPushOn = isOn
                return .none

            // MARK: - 세부 알림 토글
            case let .toggleDetailItem(index, isOn):
                guard state.detailToggles.indices.contains(index) else { return .none }
                state.detailToggles[index].isOn = isOn
                return .none

            // MARK: - 팝업 확인 버튼 (끄기)
            case .popupConfirmTapped:
                state.isMarketingPushOn = false
                state.marketingAgreementDate = nil
                return .merge(
                    .send(.popup(.hide)),
                    .send(.toast(.show("마케팅 정보 수신 해제")))
                )

            // MARK: - 팝업 취소 버튼 (알림 유지)
            case .popupCancelTapped:
                state.isMarketingPushOn = true
                return .send(.popup(.hide))

            default:
                return .none
            }
        }
    }
}

// MARK: - Model
struct PushDetailItem: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var isOn: Bool
}
