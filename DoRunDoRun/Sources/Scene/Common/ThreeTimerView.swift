//
//  ThreeTimerView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/27/25.
//

import UIKit

final class ThreeTimerView: UIView {
    private let title: String
    private let subtitle: String
    private let completion: () -> Void

    private lazy var titleLabel = UILabel(text: title, size: 40, weight: .bold, color: .init(hex: 0xD2FF3E))
    private lazy var subtitleLabel = UILabel(text: subtitle, size: 20, weight: .medium, color: .white)
    private let secondLabel = UILabel(text: "3", size: 96, weight: .bold, color: .init(hex: 0xD2FF3E))
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lime_circle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var timer: Timer?
    private var count = 4

    init(title: String, subtitle: String, completion: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.completion = completion
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        setupTimer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .black.withAlphaComponent(0.73)

        self.addSubviews(imageView, titleLabel, subtitleLabel, secondLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 293),
            imageView.heightAnchor.constraint(equalToConstant: 293),

            secondLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            secondLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            subtitleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -32),
            subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -8),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }

    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.count -= 1

            if count == 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.completion()
                self.removeFromSuperview()
            } else {
                self.secondLabel.text = "\(self.count)"
            }
        }
    }

    

    deinit {
        timer?.invalidate()
        timer = nil
    }
}
