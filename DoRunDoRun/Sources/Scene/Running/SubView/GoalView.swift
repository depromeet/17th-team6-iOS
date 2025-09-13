//
//  GoalView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/13/25.
//

import UIKit

final class GoalView: UIView {
    enum AimType {
        case distance, time, pace
        
        private var image: UIImage? {
            switch self {
                case .distance: return UIImage(named: "goal_distance")
                case .time: return UIImage(named: "goal_time")
                case .pace: return UIImage(named: "goal_pace")
            }
        }
        
        private var subtitleText: NSAttributedString {
            let text: String = switch self {
                case .distance: "러닝 거리"
                case .time: "권장 러닝 시간"
                case .pace: "권장 페이스"
            }
            return NSAttributedString.withLetterSpacing(
                text: text,
                font: .pretendard(size: 14, weight: .regular),
                px: -0.2,
                color: .init(hex: 0x82878F)
            )
        }
        
        var view: RecommendAimView {
            RecommendAimView(image: self.image, subtitle: self.subtitleText)
        }
    }
    
    private let aimTilteView = AimTitleView()
    
    private let recommendAimStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private let distanceAimView = AimType.distance.view
    private let timeAimView = AimType.time.view
    private let paceAimView = AimType.pace.view
    
    private let routineStepView = RoutineStepView()
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupStackView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        self.addSubviews(aimTilteView, recommendAimStackView, routineStepView)
        
        NSLayoutConstraint.activate([
            aimTilteView.topAnchor.constraint(equalTo: self.topAnchor, constant: 44),
            aimTilteView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            aimTilteView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            recommendAimStackView.topAnchor.constraint(equalTo: aimTilteView.bottomAnchor, constant: 28),
            recommendAimStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            recommendAimStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            routineStepView.topAnchor.constraint(equalTo: recommendAimStackView.bottomAnchor, constant: 32),
            routineStepView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            routineStepView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            routineStepView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    private func setupStackView() {
        // Add arranged subviews with fixed-width dividers in between
        recommendAimStackView.addArrangedSubview(distanceAimView)
        recommendAimStackView.addArrangedSubview(StackDivider())
        recommendAimStackView.addArrangedSubview(timeAimView)
        recommendAimStackView.addArrangedSubview(StackDivider())
        recommendAimStackView.addArrangedSubview(paceAimView)
        
        // Ensure the RecommendAimView blocks can grow to fill available space equally
        distanceAimView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeAimView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        paceAimView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        distanceAimView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timeAimView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        paceAimView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Equalize widths so the three content views share the remaining space
        NSLayoutConstraint.activate([
            distanceAimView.widthAnchor.constraint(equalTo: timeAimView.widthAnchor),
            timeAimView.widthAnchor.constraint(equalTo: paceAimView.widthAnchor)
        ])
    }
}

fileprivate final class AimTitleView: UIView {
    private let roundLabel: PaddingLabel = {
        let label = PaddingLabel(vertical: 4, horizontal: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .withLetterSpacing(
            text: "12회차",
            font: .pretendard(size: 12, weight: .medium),
            px: -0.2,
            color: .white
        )
        label.backgroundColor = UIColor(hex: 0x3E4FFF)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .withLetterSpacing(
            text: "오늘의 러닝 목표",
            font: .pretendard(size: 20, weight: .bold),
            px: -0.2,
            color: .black
        )
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .withLetterSpacing(
            text: "오늘도 두런두런과 함께 힘차게 달려볼까요?",
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .black
        )
        return label
    }()
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Goal_Character")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        self.addSubviews(roundLabel, titleLabel, subTitleLabel, characterImageView)
        
        NSLayoutConstraint.activate([
            roundLabel.topAnchor.constraint(equalTo: self.topAnchor),
            roundLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: characterImageView.leadingAnchor),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: characterImageView.leadingAnchor),
            subTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            characterImageView.heightAnchor.constraint(equalToConstant: 80),
            characterImageView.widthAnchor.constraint(equalToConstant: 80),
            characterImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            characterImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}

final class RecommendAimView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "goal_pin")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .withLetterSpacing(
            text: "타이틀",
            font: .pretendard(size: 20, weight: .bold),
            px: -0.2,
            color: .black
        )
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .withLetterSpacing(
            text: "서브 타이틀",
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: UIColor(hex: 0x82878F)
        )
        return label
    }()
    
    fileprivate init(image: UIImage?, subtitle: NSAttributedString) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        subtitleLabel.attributedText = subtitle
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        self.addSubviews(imageView, titleLabel, subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func configure(title: NSAttributedString) {
        titleLabel.attributedText = title
    }
}

private final class StackDivider: UIView {
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = UIColor(hex: 0xD7DBE3)
        self.widthAnchor.constraint(equalToConstant: 1).isActive = true
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate final class RoutineStepView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .withLetterSpacing(
            text: "구간별 루틴",
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: .black
        )
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .withLetterSpacing(
            text: "러닝 전후로 속도를 낮춰 달리면 부상 위험을 줄이고\n안전하게 달릴 수 있어요.",
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: UIColor(hex: 0x82878F)
        )
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "goal_routine_step")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0xF0F3F8)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
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
        self.addSubviews(titleLabel, subtitleLabel, imageContainerView)
        
        imageContainerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: 33),
            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -20),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -28),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            
            imageContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            imageContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
