//
//  InputField.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

import SwiftUI

struct InputField: View {
    var keyboardType: UIKeyboardType = .default
    var label: String?
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    enum InputState {
        case `default`
        case focused
        case typing
    }

    // MARK: - 상태 계산
    var state: InputState {
        if text.isEmpty {
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

    // MARK: - 뷰
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            if let label {
                TypographyText(text: label, style: .b2_500, color: .gray700, alignment: .left)
            }

            HStack(spacing: 0) {
                // Input Field
                CustomUITextField(
                    text: $text,
                    style: .b1_500,
                    textColor: UIColor(Color.gray900),
                    placeholder: placeholder,
                    placeholderColor: UIColor(Color.gray400),
                    keyboardType: keyboardType,
                    alignment: .left
                )
                .focused($isFocused)
                .frame(height: 24)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                                
                Button {
                    text = "" // 입력 전체 삭제
                } label: {
                    Image(.closeCircle, fill: .fill, size: .medium)
                        .renderingMode(.template)
                        .foregroundStyle(Color.gray300)
                }
                .opacity(state == .typing ? 1 : 0)
                .padding(.trailing, 12)
                .padding(.vertical, 14)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        InputField(label: "기본 상태", placeholder: "Label", text: .constant(""))
        InputField(label: "포커스 상태", placeholder: "Label", text: .constant("123456"))
        InputField(label: "타이핑 상태", placeholder: "Label", text: .constant("입력중"))
    }
    .padding()
    .background(Color.gray200.opacity(0.2))
}
