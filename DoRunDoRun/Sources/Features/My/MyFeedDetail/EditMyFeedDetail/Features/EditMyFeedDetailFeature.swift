//
//  EditMyFeedDetailFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation
import ComposableArchitecture
import UIKit

@Reducer
struct EditMyFeedDetailFeature {
    // MARK: - Dependencies
    @Dependency(\.selfieFeedUpdateUseCase) var selfieFeedUpdateUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var feed: SelfieFeedItem
        
        var selectedImageData: Data? = nil
        var selectedImage: UIImage? = nil
        
        var isUploading = false
        
        var networkErrorPopup = NetworkErrorPopupFeature.State()
        var serverError = ServerErrorFeature.State()
        
        enum FailedRequestType: Equatable { case updateCompleted(selectedImage: UIImage?) }
        var lastFailedRequest: FailedRequestType? = nil
    }

    // MARK: - Action
    enum Action: Equatable {
        case networkErrorPopup(NetworkErrorPopupFeature.Action)
        case serverError(ServerErrorFeature.Action)
        
        case imageDataPicked(Data)
        
        case uploadButtonTapped
        case uploadSuccess(SelfieFeedUpdateResult)
        case uploadFailure(APIError)
        
        case saveImageButtonTapped
        case saveImageSuccess
        
        case backButtonTapped
        
        enum Delegate: Equatable { case updateCompleted(feedID: Int, imageURL: String) }
        case delegate(Delegate)
    }

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.networkErrorPopup, action: \.networkErrorPopup) { NetworkErrorPopupFeature() }
        Scope(state: \.serverError, action: \.serverError) { ServerErrorFeature() }

        Reduce { state, action in
            switch action {
                
            // MARK: - 이미지 선택
            case let .imageDataPicked(data):
                let targetSize = CGSize(width: 500, height: 500)
                
                // 다운샘플링 처리
                if let downsampledImage = ImageDownsampler.downsample(imageData: data, to: targetSize),
                   let jpegData = downsampledImage.jpegData(compressionQuality: 0.8) {
                    state.selectedImage = downsampledImage        // 미리보기용
                    state.selectedImageData = jpegData            // 업로드용
                }
                return .none

            // MARK: - 업로드 버튼 탭
            case .uploadButtonTapped:
                guard let imageData = state.selectedImageData else { return .none }
                state.isUploading = true

                let dto = SelfieFeedUpdateRequestDTO(content: "오늘도 완주!", deleteSelfieImage: state.selectedImage == nil)
                let feedId = state.feed.feedID

                return .run { send in
                    do {
                        let result = try await selfieFeedUpdateUseCase.execute(
                            feedId: feedId,
                            data: dto,
                            selfieImage: imageData
                        )
                        await send(.uploadSuccess(result))
                    } catch {
                        if let apiError = error as? APIError {
                            await send(.uploadFailure(apiError))
                        } else {
                            await send(.uploadFailure(.unknown))
                        }
                    }
                }

            // MARK: - 업로드 성공
            case let .uploadSuccess(result):
                state.isUploading = false
                return .send(.delegate(.updateCompleted(feedID: state.feed.feedID, imageURL: result.updatedImageUrl)))

            // MARK: - 업로드 실패
            case let .uploadFailure(apiError):
                state.isUploading = false
                return handleAPIError(apiError)
                
            // MARK: - 피드 이미지 저장 버튼 탭
            case .saveImageButtonTapped:
                return .run { [feed = state.feed] send in
                    let image = await MyFeedImageCaptureView(feed: feed).snapshot()
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    await send(.saveImageSuccess)
                }
                
            //MARK: - 피드 이미지 저장 성공
            case .saveImageSuccess:
                print("이미지 저장 완료")
                return .none
                
            // MARK: - 재시도
            case .networkErrorPopup(.retryButtonTapped),
                 .serverError(.retryButtonTapped):
                return .send(.uploadButtonTapped)

            default:
                return .none
            }
        }
    }

    // MARK: - 에러 처리
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
