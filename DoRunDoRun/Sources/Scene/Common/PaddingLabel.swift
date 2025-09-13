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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let textInsets: UIEdgeInsets

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let adjustedSize = super.sizeThatFits(size)
        return CGSize(width: adjustedSize.width + textInsets.left + textInsets.right,
                      height: adjustedSize.height + textInsets.top + textInsets.bottom)
    }
}
