//
//  GoalSessionCell.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/19/25.
//

import UIKit

// MARK: - GoalSession

final class GoalSessionCell: UITableViewCell {
    static let identifier = String(describing: GoalSessionCell.self)
    
    // MARK: UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xFFFFFF)
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor(hex: 0xDFE4EC).cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }()
    
    private let roundLabel = UILabel()
    
    private let distanceLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    private let paceLabel = UILabel()
    
    private let checkButton: UIButton = {
        let button = UIButton(configuration: .checkmark(isChecked: false))
        return button
    }()
    
    private let firstDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xDFE4EC)
        return view
    }()
    
    private let secondDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xDFE4EC)
        return view
    }()
    
    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let attributedTitle = NSAttributedString.withLetterSpacing(
            text: "이 목표로 다시 러닝",
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: UIColor(hex: 0xFFFFFF)
        )
        
        config.attributedTitle = AttributedString(attributedTitle)
        config.background.cornerRadius = 12
        config.baseBackgroundColor = UIColor(hex: 0x3E4FFF)
        
        let button = UIButton(configuration: config)
        return button
    }()
    
    // MARK: Properties
    
    // 텍스트 그룹 레이아웃 가이드
    private let textGroupGuide = UILayoutGuide()
    
    // Retry 버튼 상단/높이 여백 제약
    private var retryButtonTopConstraint: NSLayoutConstraint!
    private var retryButtonHeightConstraint: NSLayoutConstraint!
    
    // MARK: Object lifecyle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
        
        [roundLabel, distanceLabel, firstDivider, timeLabel, secondDivider, paceLabel, checkButton, retryButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 텍스트 그룹 레이아웃 가이드 추가
        containerView.addLayoutGuide(textGroupGuide)
        
        // Retry 버튼 상단/높이 여백 제약 설정
        retryButtonTopConstraint = retryButton.topAnchor.constraint(greaterThanOrEqualTo: paceLabel.bottomAnchor, constant: 0)
        retryButtonHeightConstraint = retryButton.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // 회차 라벨
            roundLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            roundLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            // 거리
            distanceLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 4),
            distanceLabel.leadingAnchor.constraint(equalTo: roundLabel.leadingAnchor),
            
            // firstDivider
            firstDivider.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            firstDivider.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 8),
            firstDivider.widthAnchor.constraint(equalToConstant: 1),
            firstDivider.heightAnchor.constraint(equalToConstant: 14),
            
            // 시간
            timeLabel.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: firstDivider.trailingAnchor, constant: 8),
            
            // secondDivider
            secondDivider.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            secondDivider.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8),
            secondDivider.widthAnchor.constraint(equalToConstant: 1),
            secondDivider.heightAnchor.constraint(equalToConstant: 14),
            
            // 페이스
            paceLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            paceLabel.leadingAnchor.constraint(equalTo: secondDivider.trailingAnchor, constant: 8),
            
            // 텍스트 그룹 레이아웃 가이드
            textGroupGuide.topAnchor.constraint(equalTo: roundLabel.topAnchor),
            textGroupGuide.bottomAnchor.constraint(equalTo: paceLabel.bottomAnchor),
            
            // 체크 버튼 (텍스트 그룹 중앙에 정렬)
            checkButton.centerYAnchor.constraint(equalTo: textGroupGuide.centerYAnchor),
            checkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkButton.widthAnchor.constraint(equalToConstant: 28),
            checkButton.heightAnchor.constraint(equalToConstant: 28),
            
            // 재시도 버튼
            retryButtonTopConstraint,
            retryButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            retryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            retryButtonHeightConstraint,
            retryButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: Configure
    
    func configure(with viewModel: DisplayedSessionGoal) {
        roundLabel.attributedText = .withLetterSpacing(
            text: viewModel.round,
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        distanceLabel.attributedText = .withLetterSpacing(
            text: viewModel.distance,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        
        timeLabel.attributedText = .withLetterSpacing(
            text: viewModel.time,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        
        paceLabel.attributedText = .withLetterSpacing(
            text: viewModel.pace,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        
        checkButton.configuration = .checkmark(isChecked: viewModel.isCompleted)
    }
    
    func showRetryButton(_ isVisible: Bool) {
        retryButton.alpha = isVisible ? 1 : 0
        retryButtonTopConstraint.constant = isVisible ? 20 : 0
        retryButtonHeightConstraint.constant = isVisible ? 56 : 0
        setNeedsLayout()
    }
}
