//
//  InfoToastView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/19/25.
//

import UIKit

enum ToastStyle {
    case error
    
    var icon: UIImage? {
        switch self {
        case .error: return UIImage(systemName: "exclamationmark.circle.fill")
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .error: return .init(hex: 0xFF443B)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .error: return .init(hex: 0x232529, alpha: 0.6)
        }
    }
}

// MARK: InfoToast

final class InfoToastView: UIView {
    private let iconView = UIImageView()
    private let messageLabel = UILabel()
    
    init(message: String, style: ToastStyle) {
        super.init(frame: .zero)
        setupView(message: message, style: style)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView(message: String, style: ToastStyle) {
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 12
        clipsToBounds = true
        
        iconView.image = style.icon
        iconView.tintColor = style.tintColor
        iconView.contentMode = .scaleAspectFit
        
        messageLabel.attributedText = .withLetterSpacing(
            text: message,
            font: .pretendard(size: 16, weight: .medium),
            px: -0.2,
            color: .init(hex: 0xFFFFFF)
        )
        
        [iconView, messageLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            messageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

