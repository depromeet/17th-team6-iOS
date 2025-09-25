//
//  MetricView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import UIKit

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
    
    func configure(metrics: [(icon: String?, title: String, value: String)]) {
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
                // 아이콘 여부에 따른 separator 높이 분기 처리
                let separatorHeight: CGFloat = (metric.icon != nil) ? 40 : 20
                let separator = makeSeparator(height: separatorHeight)
                metricsStackView.addArrangedSubview(separator)
            }
        }
    }

    private func makeSeparator(height: CGFloat) -> UIView {
        let separator = UIView()
        separator.backgroundColor = .init(hex: 0xDFE4EC)
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.heightAnchor.constraint(equalToConstant: height)
        ])
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
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()
    
    // MARK: Object lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup

    private func setupView() {
        [imageView, valueLabel, titleLabel].forEach { stackView.addArrangedSubview($0) }
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: Configure
    
    func configure(icon: String?, title: String, value: String) {
        // 아이콘 여부에 따른 분기 처리
        if let icon = icon {
            imageView.image = UIImage(systemName: icon)
            imageView.isHidden = false
            
            // 아이콘 있을 때는 imageView 아래 spacing = 8
            stackView.setCustomSpacing(8, after: imageView)
        } else {
            imageView.isHidden = true
            
            // 아이콘 없을 때는 valueLabel이 맨 위로 올라오게 spacing = 0
            stackView.setCustomSpacing(0, after: imageView)
        }
        
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
