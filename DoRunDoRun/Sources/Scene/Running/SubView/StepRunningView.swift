//
//  WarmupView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/25/25.
//

import UIKit

protocol StepRunningViewDelegate: AnyObject {
    func didTapPassButton(type: StepRunningView.StepType)
    func didTapStopButton(type: StepRunningView.StepType)
    func didTapTerminateButton(type: StepRunningView.StepType)
    func didTapContinueButton(type: StepRunningView.StepType)
}


final class StepRunningView: UIView {
    enum StepType {
        case warmup
        case cooldown
    }
    private lazy var titleLabel = UILabel(text: self.text, size: 24, weight: .bold)
    private let text: String
    private let stepType: StepType
    weak var delegate: StepRunningViewDelegate?

    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    private let passButton = UIButton(
        title: "건너뛰기",
        font: .pretendard(size: 18, weight: .bold),
        titleColor: .init(hex: 0x3E4FFF)
    )
    private let runningLabel = UILabel(text: "러닝 시간", size: 14, weight: .medium, color: UIColor(hex: 0x747A83))
    private let timmerLabel = UILabel(text: "00:00:00", size: 32, weight: .bold, color: .black)
    private let stopButton = UIButton(
        title: "기록 정지",
        font: .pretendard(size: 16, weight: .bold),
        titleColor: .white,
        backgroundColor: .init(hex: 0x3E4FFF)
    )
    private let terminateButton = UIButton(
        title: "기록 종료",
        font: .pretendard(size: 16, weight: .bold),
        titleColor: .init(hex: 0xFF443B),
        backgroundColor: .init(hex: 0xFFE5E4)
    )
    private let continueButton = UIButton(
        title: "계속 운동하기",
        font: .pretendard(size: 16, weight: .bold),
        titleColor: .white,
        backgroundColor: .init(hex: 0x3E4FFF)
    )


    init(stepType: StepType) {
        self.stepType = stepType
        self.text = switch stepType {
            case .warmup: "웜업"
            case .cooldown: "쿨다운"
        }
        passButton.isHidden = stepType == .cooldown
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        addAction()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        stopButton.layer.cornerRadius = 12
        terminateButton.layer.cornerRadius = 12
        continueButton.layer.cornerRadius = 12

        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.backgroundColor = .clear



        self.addSubviews(emptyView, container)
        container.addSubviews(titleLabel, passButton, runningLabel, timmerLabel, stopButton, terminateButton, continueButton)

        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: self.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 247)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(lessThanOrEqualTo: passButton.leadingAnchor),

            passButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            passButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            runningLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            runningLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),

            timmerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            timmerLabel.topAnchor.constraint(equalTo: runningLabel.bottomAnchor, constant: 8),
        ])

        terminateButton.isHidden = true
        continueButton.isHidden = true

        NSLayoutConstraint.activate([
            stopButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stopButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stopButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            stopButton.heightAnchor.constraint(equalToConstant: 56),

            terminateButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            terminateButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            terminateButton.trailingAnchor.constraint(equalTo: continueButton.leadingAnchor, constant: -8),
            terminateButton.heightAnchor.constraint(equalToConstant: 56),

            continueButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.widthAnchor.constraint(equalTo: terminateButton.widthAnchor)
        ])
    }

    private func addAction() {
        let passAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.didTapPassButton(type: self.stepType)
        }
        passButton.addAction(passAction, for: .touchUpInside)

        let stopAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.stopButton.isHidden = true
            self.terminateButton.isHidden = false
            self.continueButton.isHidden = false
            self.delegate?.didTapStopButton(type: self.stepType)
        }
        stopButton.addAction(stopAction, for: .touchUpInside)

        let terminateAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.didTapTerminateButton(type: self.stepType)
        }
        terminateButton.addAction(terminateAction, for: .touchUpInside)

        let continueAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.stopButton.isHidden = false
            self.terminateButton.isHidden = true
            self.continueButton.isHidden = true
            self.delegate?.didTapContinueButton(type: self.stepType)
        }
        continueButton.addAction(continueAction, for: .touchUpInside)
    }

    func updateTime(text: String) {
        timmerLabel.text = text
    }
}
 
