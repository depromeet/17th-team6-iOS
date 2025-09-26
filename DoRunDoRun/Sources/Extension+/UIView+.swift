//
//  UIView+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/13/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
