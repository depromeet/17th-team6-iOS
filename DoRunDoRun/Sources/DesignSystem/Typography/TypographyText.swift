//
//  TypographyText.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

struct TypographyText: View {
    let text: String
    let style: TypographyStyle
    var color: Color = .gray900
    var alignment: NSTextAlignment = .center

    var body: some View {
        AttributedTextView(
            attributedText: TypographyUtility.makeAttributedString(
                text,
                style: style,
                color: UIColor(color),
                alignment: alignment
            ),
            alignment: alignment
        )
        .frame(maxWidth: .infinity)
    }
}
