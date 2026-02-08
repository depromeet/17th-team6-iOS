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
    
    @Dependency(\.analyticsTracker) var analytics

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        let entryPoint: EntryPoint
        let session: RunningSessionSummaryViewState
        var selectedImage: UIImage? = nil
        var selectedImageData: Data? = nil
        var isUploading = false
        var toast = ToastFeature.State()
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()

        @Presents var uploadSuccess: UploadSuccessFeature.State?
    }

    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case imageDataPicked(Data)
        case uploadButtonTapped
        case feedUploadSuccess
        case uploadFailure(APIError)
        case toast(ToastFeature.Action)
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        case saveImageButtonTapped
        case saveImageSuccess
        case backButtonTapped

        // Navigation
        case uploadSuccess(PresentationAction<UploadSuccessFeature.Action>)

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
            case .onAppear:
                // event
                analytics.track(.screenViewed(.createFeed))
                analytics.track(
                    .feed(.createFeedEntryCompleted(
                        runningID: String(state.session.id),
                        entryPoint: state.entryPoint
                    ))
                )
                return .none


            // MARK: - 이미지 선택
            case let .imageDataPicked(data):
                let targetSize = CGSize(width: 500, height: 500)
                if let downsampledImage = ImageDownsampler.downsample(imageData: data, to: targetSize),
                   let jpegData = downsampledImage.jpegData(compressionQuality: 0.8) {
                    state.selectedImage = downsampledImage
                    state.selectedImageData = jpegData
                    // event
                    analytics.track(
                        .feed(.photoChanged(
                            source: "gallery",
                            fileSizeKB: jpegData.count / 1024
                        ))
                    )
                }
                return .none

            // MARK: - 업로드 버튼 탭
            case .uploadButtonTapped:
                // event
                analytics.track(
                    .feed(.uploadClicked(
                        runningID: String(state.session.id)
                    ))
                )

                state.isUploading = true

                // DTO에는 텍스트 데이터만 포함
                let dto = SelfieFeedCreateRequestDTO(
                    runSessionId: state.session.id,
                    content: "오늘도 완주!"
                )

                let imageData = state.selectedImageData
                let mapImageURL = state.session.mapImageURL

                return .run { send in
                    do {
                        // 선택된 이미지가 없으면 지도 이미지를 다운로드하여 전달
                        let uploadImageData: Data?
                        if let imageData {
                            uploadImageData = imageData
                        } else if let mapImageURL {
                            uploadImageData = try? Data(contentsOf: mapImageURL)
                        } else {
                            uploadImageData = nil
                        }

                        // 이미지 데이터는 별도 파라미터로 전달
                        try await selfieFeedCreateUseCase.execute(data: dto, selfieImage: uploadImageData)
                        await send(.feedUploadSuccess)
                    } catch {
                        await send(.uploadFailure(error as? APIError ?? .unknown))
                    }
                }

            // MARK: - 업로드 성공
            case .feedUploadSuccess:
                state.isUploading = false
                // event
                analytics.track(
                    .feed(.uploadSucceeded(
                        entryPoint: state.entryPoint
                    ))
                )
                state.uploadSuccess = .init()
                return .none

            // MARK: - 업로드 실패
            case let .uploadFailure(error):
                state.isUploading = false
                // event
                analytics.track(
                    .feed(.uploadFailed(
                        errorCode: error.analyticsCode
                    ))
                )
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

            // MARK: - UploadSuccess 완료
            case .uploadSuccess(.presented(.delegate(.uploadSuccessCompleted))):
                state.uploadSuccess = nil
                return .send(.delegate(.uploadCompleted))

            default:
                return .none
            }
        }
        .ifLet(\.$uploadSuccess, action: \.uploadSuccess) { UploadSuccessFeature() }
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
