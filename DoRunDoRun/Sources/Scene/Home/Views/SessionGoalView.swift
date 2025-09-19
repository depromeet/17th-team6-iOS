//
//  SessionGoalView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/17/25.
//

import UIKit

// MARK: - SessionGoal

final class SessionGoalView: UIView {
    
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
}


final class MetricView: UIView {
    
    // MARK: UI
    
    private let metricsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: Properties

    private var metricViews: [MetricItemView] = []

    // MARK: Object lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        addSubview(metricsStackView)
        metricsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            metricsStackView.topAnchor.constraint(equalTo: topAnchor),
            metricsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metricsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            metricsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: Configure
    
    func configure(metrics: [(icon: String, title: String, value: String)]) {
        metricsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricViews.removeAll()
        
        var firstMetricView: MetricItemView?
        for (index, metric) in metrics.enumerated() {
            let metricView = MetricItemView()
            metricView.configure(icon: metric.icon, title: metric.title, value: metric.value)
            metricsStackView.addArrangedSubview(metricView)
            metricViews.append(metricView)
            
            if let first = firstMetricView {
                metricView.widthAnchor.constraint(equalTo: first.widthAnchor).isActive = true
            } else {
                firstMetricView = metricView
            }
            
            if index < metrics.count - 1 {
                let separator = makeSeparator()
                metricsStackView.addArrangedSubview(separator)
                NSLayoutConstraint.activate([
                    separator.widthAnchor.constraint(equalToConstant: 1),
                    separator.heightAnchor.constraint(equalToConstant: 40)
                ])
            }
        }
    }
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .init(hex: 0xDFE4EC)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }
}


final class MetricItemView: UIView {
    
    // MARK: UI
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.tintColor = .init(hex: 0xB5B9C0)
        return imageView
    }()
    
    private let valueLabel = UILabel()
    
    private let titleLabel = UILabel()
    
    // MARK: Object lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup

    private func setupView() {
        [imageView, valueLabel, titleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: Configure
    
    func configure(icon: String, title: String, value: String) {
        imageView.image = UIImage(systemName: icon)
        
        valueLabel.attributedText = .withLetterSpacing(
            text: value,
            font: .pretendard(size: 20, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        titleLabel.attributedText = .withLetterSpacing(
            text: title,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
    }
}
