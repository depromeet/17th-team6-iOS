//
//  AttributedTextView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI
import UIKit

struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    var alignment: NSTextAlignment = .center

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedText
        uiView.textAlignment = alignment
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0 else { return nil }
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = uiView.sizeThatFits(maxSize)
        return CGSize(width: width, height: rect.height)
    }
}
