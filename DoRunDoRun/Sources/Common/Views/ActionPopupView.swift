//
//  ActionPopupView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/24/25.
//

import SwiftUI

struct ActionPopupView: View {
    enum PopupStyle {
        case actionOnly        // 특정 액션 1개
        case actionAndCancel   // 특정 액션 + 취소(닫기) 액션
        case destructive       // 위험 액션 + 취소(닫기) 액션
    }

    let imageName: String?
    let title: String
    let message: String?
    let actionTitle: String
    let cancelTitle: String?
    let style: PopupStyle
    let onAction: () -> Void
    let onCancel: (() -> Void)?
    
    init(imageName: String? = nil,
         title: String,
         message: String?,
         actionTitle: String,
         cancelTitle: String?,
         style: PopupStyle,
         onAction: @escaping () -> Void,
         onCancel: (() -> Void)?
    ) {
        self.imageName = imageName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.cancelTitle = cancelTitle
        self.style = style
        self.onAction = onAction
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if let imageName {
                Image(imageName)
            }
            VStack(spacing: 8) {
                TypographyText(text: title, style: .t2_700)

                if let message {
                    TypographyText(text: message, style: .b2_400, color: .gray700)
                }
            }
            buttonSection
        }
        .padding(20)
        .frame(width: 298)
        .background(Color.gray0)
        .cornerRadius(16)
    }

    @ViewBuilder
    private var buttonSection: some View {
        switch style {
        case .actionOnly:
            // 특정 액션
            AppButton(title: actionTitle, style: .primary, size: .fullWidth) {
                onAction() // 특정 액션
            }

        case .actionAndCancel:
            // 특정 액션 + 취소(닫기) 액션
            HStack(spacing: 8) {
                if let cancelTitle, let onCancel {
                    AppButton(title: cancelTitle, style: .cancel, size: .fullWidth) {
                        onCancel() // 취소(닫기) 액션
                    }
                }
                AppButton(title: actionTitle, style: .primary, size: .fullWidth) {
                    onAction() // 특정 액션
                }
            }

        case .destructive:
            // 위험 액션 + 취소(닫기)
            HStack(spacing: 8) {
                if let cancelTitle, let onCancel {
                    AppButton(title: cancelTitle, style: .cancel, size: .fullWidth) {
                        onCancel() // 취소(닫기) 액션
                    }
                }
                
                AppButton(title: actionTitle, style: .destructive, size: .fullWidth) {
                    onAction() // 위험 액션
                }
            }
        }
    }
}


#Preview {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        VStack(spacing: 40) {
            // 특정 액션 팝업
            ActionPopupView(
                title: "네트워크 연결이 불안정해요.",
                message: "와이파이나 데이터 연결을 확인하고,\n다시 시도해주세요.",
                actionTitle: "확인",
                cancelTitle: nil,
                style: .actionOnly,
                onAction: {},
                onCancel: nil
            )

            // 특정 액션 + 취소(닫기) 액션 팝업
            ActionPopupView(
                title: "아직 가입하지 않은 번호예요.\n회원가입을 진행할까요?",
                message: nil,
                actionTitle: "가입하기",
                cancelTitle: "닫기",
                style: .actionAndCancel,
                onAction: {},
                onCancel: {}
            )

            // 위험 액션 + 취소(닫기) 액션 팝업
            ActionPopupView(
                title: "친구 삭제 1명",
                message: "선택된 친구 ’땡땡’이 친구목록에서\n사라져요. 정말로 삭제하시겠어요?",
                actionTitle: "삭제",
                cancelTitle: "취소",
                style: .destructive,
                onAction: {},
                onCancel: {}
            )
        }
    }
}
