//
//  UploadSuccessView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 1/9/26.
//

import SwiftUI
import ComposableArchitecture

struct UploadSuccessView: View {
    @Perception.Bindable var store: StoreOf<UploadSuccessFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 24) {
                Image(.certificationCompleted)
                    .resizable()
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    TypographyText(
                        text: "게시물 업로드 완료!",
                        style: .t2_700,
                        color: .gray900
                    )
                    TypographyText(
                        text: "오늘의 인증 게시물이 피드에 업로드되었어요.",
                        style: .b2_400,
                        color: .gray700
                    )
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
