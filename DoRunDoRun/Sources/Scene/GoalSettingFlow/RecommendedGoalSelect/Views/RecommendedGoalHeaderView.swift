//
//  RecommendedGoalHeaderView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import UIKit

final class RecommendedGoalHeaderView: UIView {
    
    // MARK: UI
    
    private let emojiImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "나에게 꼭 맞는\n목표가 준비되었어요!",
            font: .pretendard(size: 24, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    // MARK: Object cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        backgroundColor = .init(hex: 0xFFFFFF)
    
        [emojiImageView, titleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            emojiImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiImageView.widthAnchor.constraint(equalToConstant: 72),
            emojiImageView.heightAnchor.constraint(equalToConstant: 72),
            
            titleLabel.topAnchor.constraint(equalTo: emojiImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
}
