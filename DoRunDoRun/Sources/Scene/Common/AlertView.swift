//
//  AlertView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/26/25.
//

import UIKit

final class AlertView: UIView {
    private let title: String
    private lazy var titleLabel = UILabel(text: title, size: 20, weight: .bold, color: .init(hex: 0x232529))

    private let message: String
    private lazy var messageLabel = UILabel(text: message, size: 16, weight: .medium, color: .init(hex: 0x494D54))

    private let cancelButton = UIButton(title: "취소", font: .pretendard(size: 16, weight: .bold), titleColor: .init(hex: 0x494D54), backgroundColor: UIColor(hex: 0xDFE4EC))

    private let confirmText: String
    private lazy var confirmButton = UIButton(title: confirmText, font: .pretendard(size: 16, weight: .bold), titleColor: .white, backgroundColor: UIColor(hex: 0x3E4FFF))

    private let destructiveText: String
    private lazy var destructiveButton = UIButton(title: destructiveText, font: .pretendard(size: 16, weight: .bold), titleColor: .init(hex: 0xFF443B), backgroundColor: UIColor(hex: 0xFFE5E4))

    private var cancelAction: () -> Void
    private var confirmAction: () -> Void
    private var destructiveAction: () -> Void

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(title: String, message: String, confirmText: String, cancelAction: @escaping () -> Void, confirmAction: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.confirmText = confirmText
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
        self.destructiveText = ""
        self.destructiveAction = {}
        super.init(frame: .zero)
        setupUI()
        setupSuccessUI()
        addAction()
    }

    init(title: String, message: String, destructiveText: String, cancelAction: @escaping () -> Void, destructiveAction: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.destructiveText = destructiveText
        self.cancelAction = cancelAction
        self.destructiveAction = destructiveAction
        self.confirmText = ""
        self.confirmAction = {}
        super.init(frame: .zero)
        setupUI()
        setupDestructiveUI()
        addAction()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        self.backgroundColor = .black.withAlphaComponent(0.73)

        addSubview(container)

        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            container.widthAnchor.constraint(equalToConstant: 320),
        ])

        container.addSubviews(titleLabel, messageLabel, cancelButton)
        container.backgroundColor = .white
        titleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        cancelButton.layer.cornerRadius = 12

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),

            messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            cancelButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            cancelButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    private func setupSuccessUI() {
        container.addSubview(confirmButton)

        confirmButton.layer.cornerRadius = 12
        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            confirmButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            confirmButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
        ])
    }

    private func setupDestructiveUI() {
        container.addSubview(destructiveButton)

        destructiveButton.layer.cornerRadius = 12
        NSLayoutConstraint.activate([
            destructiveButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            destructiveButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            destructiveButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            destructiveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            destructiveButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
        ])
    }

    private func addAction() {
        let cancelButtonAction = UIAction { [weak self] _ in
            self?.cancelAction()
            self?.removeFromSuperview()
        }
        cancelButton.addAction(cancelButtonAction, for: .touchUpInside)
            
        let confirmButtonAction = UIAction { [weak self] _ in
            self?.confirmAction()
            self?.removeFromSuperview()
        }
        confirmButton.addAction(confirmButtonAction, for: .touchUpInside)

        let destructiveButtonAction = UIAction { [weak self] _ in
            self?.destructiveAction()
            self?.removeFromSuperview()
        }
        destructiveButton.addAction(destructiveButtonAction, for: .touchUpInside)
    }

    func show(in view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

}
