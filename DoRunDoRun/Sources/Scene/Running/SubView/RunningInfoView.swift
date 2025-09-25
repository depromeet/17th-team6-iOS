//
//  RunningInfoView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/26/25.
//

import UIKit

final class RunningInfoView: UIView {
    private let titleLabel = UILabel(text: "러닝", size: 24, weight: .bold)
    private let targetDistanceLabel = UILabel(text: "목표 거리", size: 14, weight: .medium)
    private let targetDistanceValueLabel = UILabel(text: "5.0km", size: 20, weight: .bold)

    private let currentDistanceLabel = UILabel(text: "현재 거리", size: 14, weight: .medium)
    private let currentDistanceValueLabel = UILabel(text: "1.5km", size: 32, weight: .bold, color: .init(hex: 0x3E4FFF))

    private

    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        self.backgroundColor = .clear

        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 318),
        ])


        container.addSubviews(titleLabel, targetDistanceLabel, targetDistanceValueLabel)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(lessThanOrEqualTo: targetDistanceLabel.leadingAnchor),
            container.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),

            targetDistanceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            targetDistanceLabel.trailingAnchor.constraint(equalTo: targetDistanceValueLabel.leadingAnchor),
            targetDistanceValueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            targetDistanceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }
}

