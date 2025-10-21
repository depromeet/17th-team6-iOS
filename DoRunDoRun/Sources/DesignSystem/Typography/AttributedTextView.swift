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
        
        // 1. 폰트 설정
        let font = UIFont(name: spec.weight.rawValue, size: spec.size) ?? UIFont.systemFont(ofSize: spec.size)
        
        // 2. 문단 스타일 설정 (라인 높이 및 정렬)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.minimumLineHeight = spec.lineHeight // 지정된 라인 높이
        paragraph.maximumLineHeight = spec.lineHeight
        
        // 3. 수직 중앙 정렬을 위한 offset 계산
        // 폰트가 자연스럽게 차지하는 높이를 계산합니다. (ascent + descent + leading)
        // 이 높이와 우리가 원하는 라인 높이(spec.lineHeight)의 차이를 구합니다.
        let fontLineHeight = font.ascender + abs(font.descender) + font.leading
        
        // 차이의 절반만큼 텍스트를 위로 올립니다. (양수 값은 위로 이동)
        let offset = (spec.lineHeight - fontLineHeight) / 2
        
        // 4. 속성에 baselineOffset 추가
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph,
            .kern: spec.letterSpacing,
            .foregroundColor: color,
            .baselineOffset: offset
        ]
        
        uiView.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
