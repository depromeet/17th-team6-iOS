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
    var color: Color = .primary
    var alignment: NSTextAlignment = .center

    var body: some View {
        AttributedTextView(
            text: text,
            style: style,
            color: UIColor(color),
            alignment: alignment
        )
        .fixedSize()
    }
}
