//
//  RetryGoalView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/17/25.
//

import UIKit

// MARK: - RetryGoal

final class RetryGoalView: UIView {
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "한 번 더 연습이 필요하다면",
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "이전 목표로 다시 달리기",
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        return label
    }()
    
    //TODO: 버튼 이미지 사이즈 관련 디자이너와 상의 필요
    let playButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        let image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
        
        config.image = image
        config.imagePadding = 0
        config.baseForegroundColor = UIColor(hex: 0x3E4FFF)
        config.baseBackgroundColor = UIColor(hex: 0xEDF2FF)
        config.background.cornerRadius = 16
        
        let button = UIButton(configuration: config)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        backgroundColor = .init(hex: 0xFFFFFF)
        layer.cornerRadius = 20
        
        [subtitleLabel, titleLabel, playButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            playButton.widthAnchor.constraint(equalToConstant: 32),
            playButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
