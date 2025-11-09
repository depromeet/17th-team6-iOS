//
//  NetworkErrorPopupView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

import SwiftUI

struct NetworkErrorPopupView: View {
    let onAction: () -> Void
    
    init(onAction: @escaping () -> Void) {
        self.onAction = onAction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.error)
                .resizable()
                .frame(width: 120, height: 120)
                .padding(.bottom, 12)
            VStack(spacing: 4) {
                TypographyText(text: "네트워크 연결이 불안정해요.", style: .t2_700)
                TypographyText(text: "연결 상태를 확인한 뒤 다시 시도해주세요.", style: .b2_400, color: .gray700)
            }
            .padding(.bottom, 20)
            AppButton(
                title: "다시 시도하기",
                style: .primary,
                size: .fullWidth
            ) {
                onAction()
            }
        }
        .padding(20)
        .frame(width: 298)
        .background(Color.gray0)
        .cornerRadius(16)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        VStack(spacing: 40) {
            NetworkErrorPopupView(onAction: {})
        }
    }
}
