//
//  TextInputRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/10/26.
//

import SwiftUI

struct TextInputRow: View {
    let title: String
    var required: Bool = false
    var placeholder: String
    var unit: String? = nil
    var keyboardType: UIKeyboardType = .decimalPad

    @Binding var text: String

    var body: some View {
        InputRow(title: title, required: required) {
            HStack {
                CustomUITextField(
                    text: $text,
                    style: .b1_500,
                    textColor: UIColor(Color.gray900),
                    placeholder: placeholder,
                    placeholderColor: UIColor(Color.gray300),
                    keyboardType: keyboardType,
                    alignment: .left
                )

                if let unit {
                    TypographyText(text: unit, style: .b1_500)
                }
            }
        }
    }
}

