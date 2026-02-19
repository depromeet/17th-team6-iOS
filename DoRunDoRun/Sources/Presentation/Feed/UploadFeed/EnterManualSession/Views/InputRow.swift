//
//  InputRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/10/26.
//

import SwiftUI

struct InputRow<Content: View>: View {
    let title: String
    var required: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            RowTitle(title: title, required: required)

            content()
                .padding(.vertical, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.gray100),
                    alignment: .bottom
                )
        }
    }
}

struct RowTitle: View {
    let title: String
    var required: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            TypographyText(text: title, style: .b2_500)
            if required {
                TypographyText(text: "*", style: .b2_500, color: .red)
            }
        }
    }
}
