//
//  GoalHeaderView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/19/25.
//

import UIKit

// MARK: - GoalHeader

final class GoalHeaderView: UIView {
    
    // MARK: UI
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .init(hex: 0xD7DBE3)
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel = UILabel()
    
    private let optionButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        if let image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig) {
            let rotatedImage = image.withRenderingMode(.alwaysOriginal).rotate(radians: .pi / 2)
            config.image = rotatedImage
        }
        
        config.imagePadding = 0
        config.baseForegroundColor = UIColor(hex: 0x585D64)
        
        let button = UIButton(configuration: config, primaryAction: UIAction { _ in
            print("Button Click")
        })
        return button
    }()
    
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
        backgroundColor = .init(hex: 0xEDF2FF)
        layer.cornerRadius = 16
        
        [iconImageView, titleLabel, optionButton, progressStack, progressView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            
            optionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            optionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            optionButton.widthAnchor.constraint(equalToConstant: 24),
            optionButton.heightAnchor.constraint(equalToConstant: 24),
            
            progressStack.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            progressStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            progressView.topAnchor.constraint(equalTo: progressStack.bottomAnchor, constant: 6),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Configure
    
    func configure(with viewModel: OverallGoalList.GetOverallGoal.ViewModel.DisplayedOverallGoal) {
        iconImageView.image = UIImage(systemName: viewModel.iconName)
        
        titleLabel.attributedText = .withLetterSpacing(
            text: viewModel.title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        currentLabel.attributedText = .withLetterSpacing(
            text: viewModel.currentSession,
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x3E4FFF)
        )
        
        totalLabel.attributedText = .withLetterSpacing(
            text: viewModel.totalSession,
            font: .pretendard(size: 12, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x82878F)
        )
        
        progressView.setProgress(viewModel.progress, animated: false)
    }
}
