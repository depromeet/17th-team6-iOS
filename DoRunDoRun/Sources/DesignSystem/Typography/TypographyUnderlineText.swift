//
//  TypographyUnderlineText.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI

struct TypographyUnderlineText: View {
    let text: String
    let target: String
    let style: TypographyStyle
    var color: Color = .gray500
    var underlineColor: Color? = nil
    var alignment: NSTextAlignment = .center
    var fixedSize: Bool = true
    
    var body: some View {
        AttributedTextView(
            attributedText: makeUnderlinedText(),
            alignment: alignment
        )
        .fixedSize(horizontal: fixedSize, vertical: true)
    }
    
    private func makeUnderlinedText() -> NSAttributedString {
        let result = NSMutableAttributedString()
        let parts = text.components(separatedBy: target)
        
        // 타겟 전 텍스트
        if let first = parts.first {
            result.append(
                TypographyUtility.makeAttributedString(
                    first,
                    style: style,
                    color: UIColor(color),
                    alignment: alignment
                )
            )
        }
        
        // 타겟 텍스트 (밑줄 포함)
        if parts.count > 1 {
            let underlined = TypographyUtility.makeAttributedString(
                target,
                style: style,
                color: UIColor(underlineColor ?? color),
                alignment: alignment
            ).mutableCopy() as! NSMutableAttributedString
            
            underlined.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor(underlineColor ?? color)
            ], range: NSRange(location: 0, length: underlined.length))
            
            result.append(underlined)
        }
        
        // 나머지 텍스트
        if parts.count > 1, let last = parts.last {
            result.append(
                TypographyUtility.makeAttributedString(
                    last,
                    style: style,
                    color: UIColor(color),
                    alignment: alignment
                )
            )
        }
        
        return result
    }
}
