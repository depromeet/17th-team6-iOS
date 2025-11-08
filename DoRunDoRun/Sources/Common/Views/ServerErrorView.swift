//
//  ServerErrorView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import SwiftUI

struct ServerErrorView: View {
    enum ServerErrorType {
        case notFound           //404
        case internalServer     //500
        case badGateway         //502
    }
    let serverErrorType: ServerErrorType
    let onAction: () -> Void
    
    init(
        serverErrorType: ServerErrorType,
        onAction: @escaping () -> Void
    ) {
        self.serverErrorType = serverErrorType
        self.onAction = onAction
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(.error)
                .resizable()
                .frame(width: 120, height: 120)
            VStack(spacing: 4) {
                titleSection
                messageSection
            }
            buttonSection
        }
    }
    
    @ViewBuilder
    private var titleSection: some View {
        switch serverErrorType {
        case .notFound:
            TypographyText(text: "요청하신 페이지를 찾을 수 없어요.", style: .t2_700)
        case .internalServer:
            TypographyText(text: "일시적인 오류가 발생했어요.", style: .t2_700)
        case .badGateway:
            TypographyText(text: "연결이 잠시 끊긴 것 같아요.", style: .t2_700)
        }
    }
    
    @ViewBuilder
    private var messageSection: some View {
        switch serverErrorType {
        case .notFound:
            TypographyText(text: "찾으시는 페이지가 사라졌거나 이동된 것 같아요.", style: .b2_400, color: .gray700)
        case .internalServer:
            TypographyText(text: "죄송합니다. 서버에 잠시 문제가 생겼어요.\n잠시 후 다시 시도해주세요.", style: .b2_400, color: .gray700)
        case .badGateway:
            TypographyText(text: "서버 간 연결이 불안정해 내용을 불러올 수 없어요.\n잠시 후 다시 시도해주세요.", style: .b2_400, color: .gray700)
        }
    }

    @ViewBuilder
    private var buttonSection: some View {
        switch serverErrorType {
        case .notFound:
            AppButton(title: "홈으로 돌아가기", style: .primary, size: .medium) {
                onAction()
            }
        case .internalServer:
            AppButton(title: "다시 시도하기", style: .primary, size: .medium) {
                onAction()
            }
        case .badGateway:
            AppButton(title: "다시 시도하기", style: .primary, size: .medium) {
                onAction()
            }
        }
    }
}

#Preview {
    ServerErrorView(serverErrorType: .notFound, onAction: {})
}
