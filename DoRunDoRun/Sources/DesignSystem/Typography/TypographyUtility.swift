//
//  TypographyUtility.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI

enum TypographyUtility {
    static func makeAttributedString(
        _ string: String,
        style: TypographyStyle,
        color: UIColor = .label,
        alignment: NSTextAlignment = .center
    ) -> NSAttributedString {
        let spec = style.spec
        let font = UIFont(name: spec.weight.rawValue, size: spec.size) ?? UIFont.systemFont(ofSize: spec.size)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.minimumLineHeight = spec.lineHeight
        paragraph.maximumLineHeight = spec.lineHeight
        
        let fontLineHeight = font.ascender - font.descender + font.leading
        let offset = (spec.lineHeight - fontLineHeight) / 2
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph,
            .kern: spec.letterSpacing,
            .foregroundColor: color,
            .baselineOffset: offset
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
}
