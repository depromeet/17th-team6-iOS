//
//  SessionGoalView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/17/25.
//

import UIKit

// MARK: - SessionGoal

protocol SessionGoalViewDelegate: AnyObject {
    func didTapStartButton()
}

final class SessionGoalView: UIView {
    weak var delegate: SessionGoalViewDelegate?
    // MARK: UI
    
    private let titleLabel = UILabel()
    
    private let subtitleLabel = UILabel()
    
    private let metricView = MetricView()
    
    private let startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let attributedTitle = NSAttributedString.withLetterSpacing(
            text: "러닝하러 가기",
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
    
    // MARK: Object lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        backgroundColor = .init(hex: 0xFFFFFF)
        layer.cornerRadius = 20
        
        [titleLabel, subtitleLabel, metricView, startButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            metricView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            metricView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metricView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            startButton.topAnchor.constraint(equalTo: metricView.bottomAnchor, constant: 24),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 56),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Configure
    
    func configure(with data: Home.LoadSessionGoal.ViewModel.DisplayedSessionGoal) {
        titleLabel.attributedText = .withLetterSpacing(
            text: data.title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        subtitleLabel.attributedText = .withLetterSpacing(
            text: data.subtitle,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )

        metricView.configure(metrics: [
            ("mappin.and.ellipse", "목표 거리", data.distance),
            ("clock", "권장 러닝 시간", data.time),
            ("figure.run", "권장 페이스", data.pace)
        ])
    }

    func addAction() {
        let startAction = UIAction { [weak self] _ in
            self?.delegate?.didTapStartButton()
        }
        startButton.addAction(startAction, for: .touchUpInside)
    }
}
