//
//  EditFeedImageFeature.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/11/25.
//

import ComposableArchitecture
import Foundation
import PhotosUI
import SwiftUI
import Photos

@Reducer
struct EditFeedImageFeature {
    @ObservableState
    struct State {
        var runningRecord: RunningRecord
        var backgroundImage: UIImage?
        var isBackgroundPickerPresented = false
    }

    enum Action {
        case backButtonTapped
        case downloadButtonTapped
        case saveImageToPhotos(UIImage)
        case imageSaveCompleted(Result<Void, Error>)
        case changeBackgroundButtonTapped
        case backgroundImageSelected(UIImage?)
        case postButtonTapped
        case dismissBackgroundPicker
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                // 뒤로가기
                return .none

            case .downloadButtonTapped:
                // 이미지 다운로드 트리거 - View에서 처리
                return .none

            case let .saveImageToPhotos(image):
                return .run { send in
                    do {
                        try await PHPhotoLibrary.shared().performChanges {
                            PHAssetChangeRequest.creationRequestForAsset(from: image)
                        }
                        await send(.imageSaveCompleted(.success(())))
                    } catch {
                        await send(.imageSaveCompleted(.failure(error)))
                    }
                }

            case let .imageSaveCompleted(result):
                switch result {
                case .success:
                    print("이미지 저장 성공")
                case .failure(let error):
                    print("이미지 저장 실패: \(error)")
                }
                return .none

            case .changeBackgroundButtonTapped:
                state.isBackgroundPickerPresented = true
                return .none

            case let .backgroundImageSelected(image):
                state.backgroundImage = image
                state.isBackgroundPickerPresented = false
                return .none

            case .postButtonTapped:
                // TODO: 게시물 올리기 기능 구현
                print("게시물 올리기")
                return .none

            case .dismissBackgroundPicker:
                state.isBackgroundPickerPresented = false
                return .none
            }
        }
    }
}
