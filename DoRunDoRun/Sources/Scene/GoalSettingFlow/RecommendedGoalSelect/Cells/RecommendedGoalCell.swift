//
//  RecommendedGoalCell.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import UIKit

final class RecommendedGoalCell: UITableViewCell {
    static let identifier = "RecommendedGoalCell"
    
    // MARK: UI
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel = UILabel()
    
    private let subtitleLabel = UILabel()
    
    private let metricTextView = MetricTextView()
    
    private let badgeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let attributedTitle = NSAttributedString.withLetterSpacing(
            text: "추천",
            font: .pretendard(size: 12, weight: .medium),
            px: -0.2,
            color: .white
        )
        config.attributedTitle = AttributedString(attributedTitle)
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(hex: 0x3E4FFF)
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        let button = UIButton(configuration: config)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        return view
    }()
    
    // MARK: Object cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setup() {
        selectionStyle = .none
        
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        
        [iconImageView, badgeButton, titleLabel, subtitleLabel, metricTextView].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            badgeButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            badgeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            metricTextView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            metricTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            metricTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            metricTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Configure
    
    func configure(with recommendedGoal: DisplayedRecommendedGoal) {
        iconImageView.image = UIImage(systemName: recommendedGoal.icon)
        
        titleLabel.attributedText = .withLetterSpacing(
            text: recommendedGoal.title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        subtitleLabel.attributedText = .withLetterSpacing(
            text: recommendedGoal.subTitle,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )

        metricTextView.configure(metrics: [
            ("달성 회차", recommendedGoal.count),
            ("권장 러닝 시간", recommendedGoal.time),
            ("권장 페이스", recommendedGoal.pace)
        ])
        
        badgeButton.isHidden = !recommendedGoal.isRecommended
        
        container.layer.borderColor = recommendedGoal.isSelected ? UIColor(hex: 0x3E4FFF).cgColor : UIColor(hex: 0xDFE4EC).cgColor
    }
}
