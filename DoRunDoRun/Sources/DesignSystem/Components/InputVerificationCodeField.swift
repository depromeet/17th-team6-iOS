//
//  InputVerificationCodeField.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

import SwiftUI

struct InputVerificationCodeField: View {
    @Binding var code: String
    var placeholder: String = "인증번호 6자리"
    var timerText: String
    var onResend: () -> Void
    @FocusState private var isFocused: Bool

    enum InputState {
        case `default`
        case focused
        case typing
    }

    // MARK: - 상태 계산
    private var state: InputState {
        if code.isEmpty {
            return isFocused ? .focused : .default
        } else {
            return isFocused ? .typing : .default
        }
    }

    // MARK: - Border Color Logic
    private var borderColor: Color {
        switch state {
        case .default:
            return .gray100
        case .focused, .typing:
            return .gray900
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            // MARK: - 인증번호 입력 필드
            CustomUITextField(
                text: $code,
                style: .b1_500,
                textColor: UIColor(Color.gray900),
                placeholder: placeholder,
                placeholderColor: UIColor(Color.gray400),
                keyboardType: .numberPad,
                alignment: .left,
                maxLength: 6
            )
            .focused($isFocused)
            .frame(height: 24)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // MARK: - 타이머 + 재전송 버튼
            HStack(spacing: 12) {
                TypographyText(text: timerText, style: .b2_400, color: .red)
                AppButton(title: "재전송", style: .secondary, size: .small) {
                    onResend()
                }
            }
            .padding(.trailing, 12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}

#Preview {
    VStack(spacing: 20) {
        InputVerificationCodeField(
            code: .constant(""),
            timerText: "00:45",
            onResend: {}
        )
        .padding()
        .background(Color.gray0)

        InputVerificationCodeField(
            code: .constant("123456"),
            timerText: "00:30",
            onResend: {}
        )
        .padding()
        .background(Color.gray0)
    }
}
