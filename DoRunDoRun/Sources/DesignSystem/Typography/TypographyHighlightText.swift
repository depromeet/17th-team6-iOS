//
//  TypographyHighlightText.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI

struct TypographyHighlightText: View {
    let text: String
    let target: String?
    
    var baseStyle: TypographyStyle = .b2_400
    var baseColor: Color = .gray900
    var highlightStyle: TypographyStyle = .b2_700
    var highlightColor: Color = .gray900
    
    var alignment: NSTextAlignment = .left
    var fixedSize: Bool = true

    var body: some View {
        AttributedTextView(
            attributedText: makeHighlightedMessage(),
            alignment: alignment
        )
        .fixedSize(horizontal: fixedSize, vertical: true)
    }

    private func makeHighlightedMessage() -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        // 닉네임 강조 (target이 있을 때만)
        if let target = target, !target.isEmpty {
            let highlighted = TypographyUtility.makeAttributedString(
                target,
                style: highlightStyle,
                color: UIColor(highlightColor),
                alignment: alignment
            )
            result.append(highlighted)
        }

        // 나머지 메시지
        let normalText = TypographyUtility.makeAttributedString(
            text,
            style: baseStyle,
            color: UIColor(baseColor),
            alignment: alignment
        )
        result.append(normalText)

        return result
    }
}
