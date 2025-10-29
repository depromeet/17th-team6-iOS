//
//  InputResidentNumberField.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/29/25.
//

import SwiftUI

struct InputResidentNumberField: View {
    var label: String?
    var placeholder: String
    @Binding var frontNumber: String
    @Binding var backFirstDigit: String
    @FocusState private var focusedField: Field?

    enum Field {
        case front
        case back
    }

    private var borderColor: Color {
        switch focusedField {
        case .front, .back:
            return .gray900
        default:
            return .gray100
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label {
                TypographyText(text: label, style: .b2_500, color: .gray700)
            }

            HStack(spacing: 0) {
                // MARK: - 앞 6자리 (UITextField 기반)
                CustomUITextField(
                    text: $frontNumber,
                    style: .b1_500,
                    textColor: UIColor(Color.gray900),
                    placeholder: placeholder,
                    placeholderColor: UIColor(Color.gray300),
                    keyboardType: .numberPad,
                    maxLength: 6
                )
                .focused($focusedField, equals: .front)
                .frame(width: 126, height: 24)
                .onChange(of: frontNumber) { newValue in
                    if newValue.count == 6 {
                        focusedField = .back
                    }
                }

                Spacer()

                // MARK: - 구분자
                TypographyText(text: "-", style: .b1_500)

                Spacer()

                // MARK: - 뒤 7자리
                HStack(spacing: 8) {
                    // 항상 UITextField 유지
                    ZStack {
                        if backFirstDigit.isEmpty {
                            Circle()
                                .fill(Color.gray300)
                                .frame(width: 10, height: 10)
                        }

                        CustomUITextField(
                            text: $backFirstDigit,
                            style: .b1_500,
                            textColor: UIColor(Color.gray900),
                            placeholder: "",
                            placeholderColor: .clear,
                            keyboardType: .numberPad,
                            maxLength: 1
                        )
                        .focused($focusedField, equals: .back)
                        .frame(width: 14, height: 14)
                        .opacity(1)
                    }


                    // 나머지 6자리 마스킹
                    ForEach(0..<6, id: \.self) { _ in
                        Circle()
                            .fill(Color.gray900)
                            .frame(width: 10, height: 10)
                    }
                }
                .frame(width: 126)

                .focused($focusedField, equals: .back)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }
}

#Preview {
    ZStack {
        Color.blue100.ignoresSafeArea()
        VStack(spacing: 24) {
            InputResidentNumberField(placeholder: "000000", frontNumber: .constant(""), backFirstDigit: .constant(""))
            InputResidentNumberField(placeholder: "000000", frontNumber: .constant("000000"), backFirstDigit: .constant(""))
            InputResidentNumberField(placeholder: "000000", frontNumber: .constant("000000"), backFirstDigit: .constant("1"))
        }
        .padding(20)
    }
}
