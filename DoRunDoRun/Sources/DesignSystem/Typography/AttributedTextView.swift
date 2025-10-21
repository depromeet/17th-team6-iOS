//
//  AttributedTextView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI
import UIKit

struct AttributedTextView: UIViewRepresentable {
    let text: String
    let style: TypographyStyle
    var color: UIColor = .label
    var alignment: NSTextAlignment = .center

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.textAlignment = alignment
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        let spec = style.spec
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.minimumLineHeight = spec.lineHeight
        paragraph.maximumLineHeight = spec.lineHeight

        // Pretendard 폰트 적용
        let font = UIFont(name: spec.weight.rawValue, size: spec.size) ?? UIFont.systemFont(ofSize: spec.size)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph,
            .kern: spec.letterSpacing,
            .foregroundColor: color
        ]

        uiView.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
