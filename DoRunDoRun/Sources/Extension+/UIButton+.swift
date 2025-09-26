//
//  UIButton+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/25/25.
//

import UIKit

extension UIButton {
    convenience init(title: String, font: UIFont, titleColor: UIColor, backgroundColor: UIColor = .clear) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.backgroundColor = backgroundColor
    }
}
