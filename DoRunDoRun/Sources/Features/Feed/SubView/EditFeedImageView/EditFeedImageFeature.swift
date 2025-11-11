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
                // TODO: 이미지 다운로드 기능 구현
                print("다운로드 버튼 탭")
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
