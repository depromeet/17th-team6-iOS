//
//  UILabel+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/25/25.
//

import UIKit

extension UILabel {
    convenience init(text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor = .black) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        self.font = .pretendard(size: size, weight: weight)
        self.textColor = color
    }
}
