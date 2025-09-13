//
//  NSAttributedString+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/13/25.
//

import UIKit

extension NSAttributedString {
    static func withLetterSpacing(text: String, font: UIFont, px: CGFloat, color: UIColor = .label) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .kern: px,
            .foregroundColor: color
        ])
    }
}
