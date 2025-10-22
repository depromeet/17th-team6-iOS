//
//  TypographyUnderlineText.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI

struct TypographyUnderlineText: View {
    let text: String
    let target: String
    let style: TypographyStyle
    var color: Color = .primary
    var underlineColor: Color? = nil
    var underlineOffset: CGFloat = 1
    var underlineHeight: CGFloat = 1

    @State private var underlineWidth: CGFloat = 0

    var body: some View {
        let parts = text.components(separatedBy: target)
        HStack(spacing: 0) {
            TypographyText(text: parts.first ?? "", style: style, color: color)

            if parts.count > 1 {
                ZStack(alignment: .bottom) {
                    // “로그인” 영역만 width 측정
                    TypographyText(text: target, style: style, color: underlineColor ?? color)
                        .fixedSize() // 텍스트 크기 고정
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        underlineWidth = proxy.size.width
                                    }
                            }
                        )

                    Rectangle()
                        .fill(underlineColor ?? color)
                        .frame(width: underlineWidth, height: underlineHeight)
                        .offset(y: underlineOffset)
                }

                TypographyText(text: parts[1], style: style, color: color)
            }
        }
    }
}
