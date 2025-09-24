//
//  OverallGoalView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/17/25.
//

import UIKit

// MARK: - OverallGaol

final class OverallGoalView: UIView {
    
    // MARK: UI
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .init(hex: 0xD7DBE3)
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel = UILabel()
    
    //TODO: 버튼 이미지 사이즈 관련 디자이너와 상의 필요
    let viewAllButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let attributedTitle = NSAttributedString.withLetterSpacing(
            text: "전체보기",
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = UIImage(systemName: "chevron.forward", withConfiguration: imageConfig)
        
        config.attributedTitle = AttributedString(attributedTitle)
        config.contentInsets = .zero
        config.image = image
        config.imagePadding = 2
        config.imagePlacement = .trailing
        config.baseForegroundColor = .init(hex: 0x585D64)
        config.baseBackgroundColor = .red
        
        let button = UIButton(configuration: config)
        return button
    }()

    private let distanceTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "목표 거리",
            font: .pretendard(size: 12, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x82878F)
        )
        return label
    }()
    
    private let distanceValueLabel = UILabel()
    
    private let timeTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "목표 시간",
            font: .pretendard(size: 12, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x82878F)
        )
        return label
    }()
    
    private let timeValueLabel = UILabel()
    
    private let currentLabel = UILabel()
    
    private let totalLabel = UILabel()
    
    private lazy var progressStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currentLabel, totalLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .init(hex: 0xD7DBE3)
        progress.progressTintColor = .init(hex: 0x3E4FFF)
        progress.layer.cornerRadius = 5
        progress.clipsToBounds = true
        return progress
    }()
    
    // MARK: Object lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        backgroundColor = .init(hex: 0xFFFFFF)

        [iconImageView, titleLabel, viewAllButton, distanceTitleLabel, distanceValueLabel, timeTitleLabel, timeValueLabel, progressStack, progressView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),

            viewAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            viewAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            distanceTitleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            distanceTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            distanceValueLabel.topAnchor.constraint(equalTo: distanceTitleLabel.bottomAnchor, constant: 2),
            distanceValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            timeTitleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            timeTitleLabel.leadingAnchor.constraint(equalTo: distanceValueLabel.trailingAnchor, constant: 40),

            timeValueLabel.topAnchor.constraint(equalTo: timeTitleLabel.bottomAnchor, constant: 2),
            timeValueLabel.leadingAnchor.constraint(equalTo: timeTitleLabel.leadingAnchor),

            progressStack.topAnchor.constraint(equalTo: distanceValueLabel.bottomAnchor, constant: 16),
            progressStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),

            progressView.topAnchor.constraint(equalTo: progressStack.bottomAnchor, constant: 6),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            progressView.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    // MARK: Configure
    
    func configure(with data: Home.LoadOverallGoal.ViewModel.DisplayedGoal) {
        // TODO: 디자인 확정 후 URL 기반 이미지로 교체 (Kingfisher 등 라이브러리 활용 예정)
        iconImageView.image = UIImage(systemName: data.iconName)
        
        titleLabel.attributedText = .withLetterSpacing(
            text: data.title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        distanceValueLabel.attributedText = .withLetterSpacing(
            text: data.distance,
            font: .pretendard(size: 28, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x3B3E43)
        )
        
        timeValueLabel.attributedText = .withLetterSpacing(
            text: data.time,
            font: .pretendard(size: 28, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x3B3E43)
        )
        
        currentLabel.attributedText = .withLetterSpacing(
            text: data.currentSession,
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x3E4FFF)
        )
        totalLabel.attributedText = .withLetterSpacing(
            text: data.totalSession,
            font: .pretendard(size: 12, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x82878F)
        )
        
        // TODO: 애니메이션 관련 디자이너와 상의 필요
        progressView.setProgress(data.progress, animated: false)
    }
}
