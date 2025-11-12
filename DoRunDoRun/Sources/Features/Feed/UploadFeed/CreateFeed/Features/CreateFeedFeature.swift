//
//  CreateFeedFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import Foundation
import UIKit
import ComposableArchitecture

@Reducer
struct CreateFeedFeature {
    // MARK: - Dependencies
    @Dependency(\.selfieFeedCreateUseCase) var selfieFeedCreateUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        let session: RunningSessionSummaryViewState
        var selectedImage: UIImage? = nil
        var selectedImageData: Data? = nil
        var isUploading = false
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
    }

    // MARK: - Action
    enum Action: Equatable {
        case imageDataPicked(Data)
        case uploadButtonTapped
        case uploadSuccess
        case uploadFailure(APIError)
        case toast(ToastFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        case saveImageButtonTapped
        case saveImageSuccess
        case backButtonTapped
        enum DelegateAction: Equatable {
            case uploadCompleted
        }
        case delegate(DelegateAction)
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.toast, action: \.toast) { ToastFeature() }
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {

            // MARK: - 이미지 선택
            case let .imageDataPicked(data):
                let targetSize = CGSize(width: 500, height: 500)
                if let downsampledImage = ImageDownsampler.downsample(imageData: data, to: targetSize),
                   let jpegData = downsampledImage.jpegData(compressionQuality: 0.8) {
                    state.selectedImage = downsampledImage
                    state.selectedImageData = jpegData
                }
                return .none

            // MARK: - 업로드 버튼 탭
            case .uploadButtonTapped:
                guard let imageData = state.selectedImageData else { return .none }
                state.isUploading = true

                // DTO에는 텍스트 데이터만 포함
                let dto = SelfieFeedCreateRequestDTO(
                    runningSessionId: state.session.id,
                    content: "오늘도 완주!"
                )

                return .run { send in
                    do {
                        // 이미지 데이터는 별도 파라미터로 전달
                        try await selfieFeedCreateUseCase.execute(data: dto, selfieImage: imageData)
                        await send(.uploadSuccess)
                    } catch {
                        await send(.uploadFailure(error as? APIError ?? .unknown))
                    }
                }

            // MARK: - 업로드 성공
            case .uploadSuccess:
                state.isUploading = false
                return .send(.delegate(.uploadCompleted))

            // MARK: - 업로드 실패
            case let .uploadFailure(error):
                state.isUploading = false
                return handleAPIError(error)
                
            // MARK: - 피드 이미지 저장 버튼 탭
            case .saveImageButtonTapped:
                return .run { [session = state.session, selectedImage = state.selectedImage] send in
                    let image = await CreateFeedCaptureView(session: session, selectedImage: selectedImage).snapshot()
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    await send(.saveImageSuccess)
                }
                
            //MARK: - 피드 이미지 저장 성공
            case .saveImageSuccess:
                return .send(.toast(.show("이미지를 저장했어요.")))

            default:
                return .none
            }
        }
    }
}

private extension CreateFeedFeature {
    func handleAPIError(_ apiError: APIError) -> Effect<Action> {
        switch apiError {
        case .networkError: return .send(.networkErrorPopup(.show))
        case .notFound: return .send(.serverError(.show(.notFound)))
        case .internalServer: return .send(.serverError(.show(.internalServer)))
        case .badGateway: return .send(.serverError(.show(.badGateway)))
        default: return .none
        }
    }
}
