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
    // MARK: - Dependencies
    @Dependency(\.userProfileUpdateUseCase) var updateUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        var profileImage: UIImage? = nil
        var profileImageURL: String? = nil
        var nickname: String = ""
        var isNicknameValid: Bool {
            nickname.count >= 2 && nickname.count <= 8
        }
        var isLoading: Bool = false
    }

    // MARK: - Action
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toast(ToastFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)

        // 내부 동작
        case profileImageButtonTapped
        case imageDataPicked(Data)

        // 버튼 액션
        case bottomButtonTapped

        // 서버 응답
        case updateProfileSuccess(String?)
        case updateProfileFailure(APIError)

        // 상위 피처에서 처리
        case completed
        case backButtonTapped
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - 이미지 선택
            case let .imageDataPicked(data):
                let targetSize = CGSize(width: 300, height: 300)
                if let image = ImageDownsampler.downsample(imageData: data, to: targetSize) {
                    state.profileImage = image
                }
                return .none

            // MARK: - 저장 버튼 탭
            case .bottomButtonTapped:
                guard state.isNicknameValid else {
                    return .send(.toast(.show("2-8자 이내로 닉네임을 입력해주세요.")))
                }

                // 닉네임 + 이미지 옵션 설정
                let imageOption: UserProfileUpdateRequestDTO.ImageOption
                if state.profileImage != nil {
                    imageOption = .set
                } else {
                    imageOption = .keep // 기본값
                }

                let request = UserProfileUpdateRequestDTO(
                    nickname: state.nickname,
                    imageOption: imageOption
                )

                state.isLoading = true

                // PATCH 요청 실행
                return .run { [request, profileImage = state.profileImage] send in
                    do {
                        let imageData = profileImage?.jpegData(compressionQuality: 0.8)
                        let updatedURL = try await updateUseCase.execute(
                            request: request,
                            profileImageData: imageData
                        )
                        await send(.updateProfileSuccess(updatedURL))
                    } catch {
                        if let apiError = error as? APIError {
                            await send(.updateProfileFailure(apiError))
                        } else {
                            await send(.updateProfileFailure(.unknown))
                        }
                    }
                }

            // MARK: - 서버 응답 처리
            case let .updateProfileSuccess(url):
                state.isLoading = false
                if let url {
                    UserManager.shared.profileImageURL = url
                }
                UserManager.shared.nickname = state.nickname
                return .merge(
                    .send(.toast(.show("프로필이 수정되었습니다."))),
                    .send(.completed)
                )
                
            case let .updateProfileFailure(apiError):
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
                
            // MARK: - 재시도
            case .networkErrorPopup(.retryButtonTapped),
                    .serverError(.retryButtonTapped):
                return .send(.bottomButtonTapped)

            default:
                return .none
            }
        }
    }
}
