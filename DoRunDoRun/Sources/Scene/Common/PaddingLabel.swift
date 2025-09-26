//
//  PaddingLabel.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/13/25.
//


import UIKit

class PaddingLabel: UILabel {
    init(padding: UIEdgeInsets) {
        self.textInsets = padding
        super.init()
    }
    
    init(vertical: CGFloat, horizontal: CGFloat) {
        self.textInsets = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let textInsets: UIEdgeInsets

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        guard originalSize != CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) else {
            return originalSize
        }
        return CGSize(
            width: originalSize.width + textInsets.left + textInsets.right,
            height: originalSize.height + textInsets.top + textInsets.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let availableSize = CGSize(
            width: size.width - textInsets.left - textInsets.right,
            height: size.height - textInsets.top - textInsets.bottom
        )
        let originalSize = super.sizeThatFits(availableSize)
        return CGSize(
            width: originalSize.width + textInsets.left + textInsets.right,
            height: originalSize.height + textInsets.top + textInsets.bottom
        )
    }
}
