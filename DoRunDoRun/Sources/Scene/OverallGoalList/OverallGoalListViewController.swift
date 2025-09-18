//
//  OverallGoalListViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListDisplayLogic: AnyObject {
    
}

final class OverallGoalListViewController: UIViewController {
    var interactor: OverallGoalListBusinessLogic?
    var router: (OverallGoalListRoutingLogic & OverallGoalListDataPassing)?
    
    // MARK: UI
    
    private let headerView = GoalHeaderView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: Properties
    
    private var expandedIndexPath: IndexPath?
    
    // MARK: Object lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupTableView()
        
        // FIXME: 이후 Display에서 처리할 예정
        headerView.configure(
            iconName: "flag.fill",
            title: "10km 마라톤 완주",
            currentSession: "12회차",
            totalSession: "/ 총 20회",
            progress: 0.6
        )
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = OverallGoalListInteractor()
        let presenter = OverallGoalListPresenter()
        let router = OverallGoalListRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    private func setupNavigationBar() {
        
    }
    
    private func setupView() {
        view.backgroundColor = .init(hex: 0xFFFFFF)
        
        [headerView, tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 26),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GoalSessionCell.self, forCellReuseIdentifier: GoalSessionCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

}

extension OverallGoalListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GoalSessionCell.identifier, for: indexPath) as? GoalSessionCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        // FIXME: 이후 Display에서 처리할 예정
        let isChecked = (indexPath.row <= 3)
        cell.configure(
            round: "\(indexPath.row + 1)회차",
            distance: "1km",
            time: "1:12:03",
            pace: "6'74''",
            isChecked: isChecked
        )
        
        let shouldShowRetry = (indexPath == expandedIndexPath) && isChecked
        cell.showRetryButton(shouldShowRetry)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isChecked = (indexPath.row <= 3)
        
        if isChecked {
            let previousExpandedIndexPath = expandedIndexPath
            expandedIndexPath = (expandedIndexPath == indexPath) ? nil : indexPath
            
            tableView.beginUpdates()
            if let previous = previousExpandedIndexPath {
                tableView.reloadRows(at: [previous], with: .automatic)
            }
            if let current = expandedIndexPath {
                tableView.reloadRows(at: [current], with: .automatic)
            }
            tableView.endUpdates()
        } else {
            showToast(message: "이전 회차를 끝내야 도전할 수 있어요.", style: .error)
        }
    }
}

extension OverallGoalListViewController: OverallGoalListDisplayLogic {
    
}

// MARK: - GoalHeaderView
final class GoalHeaderView: UIView {
    
    // MARK: UI
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .init(hex: 0xD7DBE3)
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel = UILabel()
    
    private let optionButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        if let image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig) {
            let rotatedImage = image.withRenderingMode(.alwaysOriginal).rotate(radians: .pi / 2)
            config.image = rotatedImage
        }
        
        config.imagePadding = 0
        config.baseForegroundColor = UIColor(hex: 0x585D64)
        
        let button = UIButton(configuration: config, primaryAction: UIAction { _ in
            print("Button Click")
        })
        return button
    }()
    
    private let currentLabel = UILabel()
    
    private let totalLabel = UILabel()
    
    private lazy var progressStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currentLabel, totalLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .init(hex: 0xD7DBE3)
        progress.progressTintColor = .init(hex: 0x3E4FFF)
        progress.layer.cornerRadius = 5
        progress.clipsToBounds = true
        return progress
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
        backgroundColor = .init(hex: 0xEDF2FF)
        layer.cornerRadius = 16
        
        [iconImageView, titleLabel, optionButton, progressStack, progressView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            
            optionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            optionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            optionButton.widthAnchor.constraint(equalToConstant: 24),
            optionButton.heightAnchor.constraint(equalToConstant: 24),
            
            progressStack.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            progressStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            progressView.topAnchor.constraint(equalTo: progressStack.bottomAnchor, constant: 6),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Configure
    
    // TODO: 현재는 각각 항목을 전달 받고 있으나, 이후 ViewModel로 교체 예정
    func configure(iconName: String, title: String, currentSession: String, totalSession: String, progress: Float) {
        iconImageView.image = UIImage(systemName: iconName)
        
        titleLabel.attributedText = .withLetterSpacing(
            text: title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        currentLabel.attributedText = .withLetterSpacing(
            text: currentSession,
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x3E4FFF)
        )
        
        totalLabel.attributedText = .withLetterSpacing(
            text: totalSession,
            font: .pretendard(size: 12, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x82878F)
        )
        
        progressView.setProgress(progress, animated: false)
    }
}

// MARK: - GoalSessionCell
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
    
    func configure(round: String, distance: String, time: String, pace: String, isChecked: Bool) {
        roundLabel.attributedText = .withLetterSpacing(
            text: round,
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        distanceLabel.attributedText = .withLetterSpacing(
            text: distance,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x82878F)
        )
        
        timeLabel.attributedText = .withLetterSpacing(
            text: time,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        paceLabel.attributedText = .withLetterSpacing(
            text: pace,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        checkButton.configuration = .checkmark(isChecked: isChecked)
    }
    
    func showRetryButton(_ isVisible: Bool) {
        retryButton.alpha = isVisible ? 1 : 0
        retryButtonTopConstraint.constant = isVisible ? 20 : 0
        retryButtonHeightConstraint.constant = isVisible ? 56 : 0
        setNeedsLayout()
    }
}

final class ToastView: UIView {
    private let iconView = UIImageView()
    private let messageLabel = UILabel()
    
    init(message: String, style: ToastStyle) {
        super.init(frame: .zero)
        setupView(message: message, style: style)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView(message: String, style: ToastStyle) {
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 12
        clipsToBounds = true
        
        iconView.image = style.icon
        iconView.tintColor = style.tintColor
        iconView.contentMode = .scaleAspectFit
        
        messageLabel.attributedText = .withLetterSpacing(
            text: message,
            font: .pretendard(size: 16, weight: .medium),
            px: -0.2,
            color: .init(hex: 0xFFFFFF)
        )
        
        [iconView, messageLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            messageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

enum ToastStyle {
    case error
    
    var icon: UIImage? {
        switch self {
        case .error: return UIImage(systemName: "exclamationmark.circle.fill")
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .error: return .init(hex: 0xFF443B)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .error: return .init(hex: 0x232529, alpha: 0.6)
        }
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        var newSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        
        // scale 보존
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            return self
        }
        
        // 중심 이동 후 회전
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        
        // 이미지 그리기 (중심 맞춰서)
        context.scaleBy(x: 1.0, y: -1.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2,
                          width: size.width, height: size.height)
        context.draw(cgImage, in: rect)
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage ?? self
    }
}

extension UIButton.Configuration {
    static func checkmark(isChecked: Bool) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        config.image = UIImage(systemName: "checkmark", withConfiguration: imageConfig)
        config.imagePadding = 0
        config.background.cornerRadius = 14

        if isChecked {
            config.baseForegroundColor = UIColor(hex: 0xFFFFFF)
            config.baseBackgroundColor = UIColor(hex: 0x3E4FFF)
        } else {
            config.baseForegroundColor = UIColor(hex: 0x8F949C)
            config.baseBackgroundColor = UIColor(hex: 0xDFE4EC)
        }
        return config
    }
}

extension UIViewController {
    func showToast(message: String, style: ToastStyle = .error, delay: TimeInterval = 1.0) {
        let toast = ToastView(message: message, style: style)
        toast.alpha = 0
        
        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            toast.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: {
                toast.alpha = 0
            }, completion: { _ in
                toast.removeFromSuperview()
            })
        }
    }
}
