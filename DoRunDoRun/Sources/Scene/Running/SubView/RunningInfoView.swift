//
//  RunningInfoView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/26/25.
//

import UIKit

protocol RunningInfoViewDelegate: AnyObject {
    func didTapTerminateButton()
    func didTapContinueButton()
    func didTapStopButton()
}

final class RunningInfoView: UIView {
    private let titleLabel = UILabel(text: "러닝", size: 24, weight: .bold)
    private let targetDistanceLabel = UILabel(text: "목표 거리", size: 14, weight: .medium, color: .init(hex: 0x747A83))
    private let targetDistanceValueLabel = UILabel(text: "5.0km", size: 20, weight: .bold)

    private let currentDistanceLabel = UILabel(text: "현재 거리", size: 14, weight: .medium)
    private let currentDistanceValueLabel = UILabel(text: "1.5km", size: 32, weight: .bold, color: .init(hex: 0x3E4FFF))

    private let timerLabel = UILabel(text: "시간", size: 14, weight: .medium, color: UIColor(hex: 0x747A83))
    private let timerValueLabel = UILabel(text: "00:00:00", size: 32, weight: .bold, color: UIColor(hex: 0x232529))

    private let paceLabel = UILabel(text: "평균 페이스", size: 14, weight: .medium, color: UIColor(hex: 0x747A83))
    private let paceValueLabel = UILabel(text: "00'00''", size: 20, weight: .bold)

    private let cadenceLabel = UILabel(text: "케이던스", size: 14, weight: .medium, color: UIColor(hex: 0x747A83))
    private let cadenceValueLabel = UILabel(text: "000", size: 20, weight: .bold)

    private let stopButton = UIButton(title: "기록 정지", font: .pretendard(size: 16, weight: .bold), titleColor: .white, backgroundColor: UIColor(hex: 0x3E4FFF))
    private let terminateButton = UIButton(title: "기록 종료", font: .pretendard(size: 16, weight: .bold), titleColor: UIColor(hex: 0xFF443B), backgroundColor: UIColor(hex: 0xFFE5E4))
    private let continueButton = UIButton(title: "계속 운동하기", font: .pretendard(size: 16, weight: .bold), titleColor: .white, backgroundColor: UIColor(hex: 0x3E4FFF))

    weak var delegate: RunningInfoViewDelegate?

    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
        view.backgroundColor = .white
        return view
    }()

    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        addAction()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        self.backgroundColor = .clear

        addSubview(container)

        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 318),
        ])


        container.addSubviews(titleLabel, targetDistanceLabel, targetDistanceValueLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: targetDistanceLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),

            targetDistanceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            targetDistanceLabel.trailingAnchor.constraint(equalTo: targetDistanceValueLabel.leadingAnchor, constant: -8),
            targetDistanceValueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            targetDistanceValueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])

        stopButton.layer.cornerRadius = 12
        container.addSubviews(currentDistanceLabel, currentDistanceValueLabel, timerLabel, timerValueLabel, paceLabel, paceValueLabel, cadenceLabel, cadenceValueLabel, stopButton)
        NSLayoutConstraint.activate([
            currentDistanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            currentDistanceLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),

            currentDistanceValueLabel.topAnchor.constraint(equalTo: currentDistanceLabel.bottomAnchor),
            currentDistanceValueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),

            timerLabel.leadingAnchor.constraint(equalTo: container.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: currentDistanceLabel.topAnchor),

            timerValueLabel.leadingAnchor.constraint(equalTo: container.centerXAnchor),
            timerValueLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor),

            paceLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            paceLabel.topAnchor.constraint(equalTo: currentDistanceValueLabel.bottomAnchor, constant: 16),
            paceValueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            paceValueLabel.topAnchor.constraint(equalTo: paceLabel.bottomAnchor, constant: 2),

            cadenceLabel.leadingAnchor.constraint(equalTo: container.centerXAnchor),
            cadenceLabel.topAnchor.constraint(equalTo: timerValueLabel.bottomAnchor, constant: 16),
            cadenceValueLabel.leadingAnchor.constraint(equalTo: container.centerXAnchor),
            cadenceValueLabel.topAnchor.constraint(equalTo: cadenceLabel.bottomAnchor, constant: 2),

            stopButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stopButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stopButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            stopButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        terminateButton.layer.cornerRadius = 12
        continueButton.layer.cornerRadius = 12
        terminateButton.isHidden = true
        continueButton.isHidden = true
        container.addSubviews(terminateButton, continueButton)
        NSLayoutConstraint.activate([
            terminateButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            terminateButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            terminateButton.trailingAnchor.constraint(equalTo: continueButton.leadingAnchor, constant: -8),
            terminateButton.heightAnchor.constraint(equalToConstant: 56),

            continueButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.widthAnchor.constraint(equalTo: terminateButton.widthAnchor),
        ])
    }

    private func addAction() {
        let stopAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.stopButton.isHidden = true
            self.terminateButton.isHidden = false
            self.continueButton.isHidden = false
            delegate?.didTapStopButton()
        }
        stopButton.addAction(stopAction, for: .touchUpInside)

        let terminateAction = UIAction { [weak self] _ in
            guard let self else { return }
            delegate?.didTapTerminateButton()
        }
        terminateButton.addAction(terminateAction, for: .touchUpInside)

        let continueAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.stopButton.isHidden = false
            self.terminateButton.isHidden = true
            self.continueButton.isHidden = true
            delegate?.didTapContinueButton()
        }
        continueButton.addAction(continueAction, for: .touchUpInside)
    }

    func update(metrics: RunningMetricsViewModel) {
        currentDistanceValueLabel.text = metrics.distance
        timerValueLabel.text = metrics.elapsed
        paceValueLabel.text = metrics.pace
        cadenceValueLabel.text = metrics.cadence
    }
}

