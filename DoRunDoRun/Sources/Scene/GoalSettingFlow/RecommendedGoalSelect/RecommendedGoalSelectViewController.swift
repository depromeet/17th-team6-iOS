//
//  RecommendedGoalSelectViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RecommendedGoalSelectDisplayLogic: AnyObject {
    func displayRecommendedGoals(viewModel: RecommendedGoalSelect.LoadRecommendedGoals.ViewModel)
    func displaySelectedRecommendedGoal(viewModel: RecommendedGoalSelect.SelectRecommendedGoal.ViewModel)
}

final class RecommendedGoalSelectViewController: UIViewController {
    var interactor: RecommendedGoalSelectBusinessLogic?
    var router: (RecommendedGoalSelectRoutingLogic & RecommendedGoalSelectDataPassing)?
    
    // MARK: UI

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        return tableView
    }()

    private let startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let attributedTitle = NSAttributedString.withLetterSpacing(
            text: "두런두런 시작하기",
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
    
    private var displayedRecommendedGoals: [DisplayedRecommendedGoal] = []
    
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
        setupActions()
        
        interactor?.loadRecommendedGoals(request: .init())
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = RecommendedGoalSelectInteractor()
        let presenter = RecommendedGoalSelectPresenter()
        let router = RecommendedGoalSelectRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .init(hex: 0x1C1B1F)
    }
    
    private func setupView() {
        view.backgroundColor = .init(hex: 0xFFFFFF)

        [tableView, startButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -12),
            
            // StartButton
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecommendedGoalCell.self, forCellReuseIdentifier: RecommendedGoalCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        let headerView = RecommendedGoalHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 192))
        tableView.tableHeaderView = headerView
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc private func didTapStart() {
        // Home 화면으로 이동
    }
}

extension RecommendedGoalSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRecommendedGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecommendedGoalCell.identifier, for: indexPath) as? RecommendedGoalCell else {
            return UITableViewCell()
        }
        let recommendedGoal = displayedRecommendedGoals[indexPath.row]
        cell.configure(with: recommendedGoal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.selectRecommendedGoal(request: .init(index: indexPath.row))
    }
}

extension RecommendedGoalSelectViewController: RecommendedGoalSelectDisplayLogic {
    func displayRecommendedGoals(viewModel: RecommendedGoalSelect.LoadRecommendedGoals.ViewModel) {
        displayedRecommendedGoals = viewModel.displayedRecommendedGoals
        tableView.reloadData()
    }
    
    func displaySelectedRecommendedGoal(viewModel: RecommendedGoalSelect.SelectRecommendedGoal.ViewModel) {
        displayedRecommendedGoals = viewModel.displayedGoals
        let indexPaths = [
            IndexPath(row: viewModel.previousIndex, section: 0),
            IndexPath(row: viewModel.selectedIndex, section: 0)
        ]
        tableView.reloadRows(at: indexPaths, with: .none)
    }
}

// MARK: - HeaderView
final class RecommendedGoalHeaderView: UIView {
    
    // MARK: UI
    
    private let emojiImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "나에게 꼭 맞는\n목표가 준비되었어요!",
            font: .pretendard(size: 24, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    // MARK: Object cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        backgroundColor = .init(hex: 0xFFFFFF)
    
        [emojiImageView, titleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            emojiImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiImageView.widthAnchor.constraint(equalToConstant: 72),
            emojiImageView.heightAnchor.constraint(equalToConstant: 72),
            
            titleLabel.topAnchor.constraint(equalTo: emojiImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - Cell
final class RecommendedGoalCell: UITableViewCell {
    static let identifier = "RecommendedGoalCell"
    
    // MARK: UI
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel = UILabel()
    
    private let subtitleLabel = UILabel()
    
    private let metricTextView = MetricTextView()
    
    private let badgeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let attributedTitle = NSAttributedString.withLetterSpacing(
            text: "추천",
            font: .pretendard(size: 12, weight: .medium),
            px: -0.2,
            color: .white
        )
        config.attributedTitle = AttributedString(attributedTitle)
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(hex: 0x3E4FFF)
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        let button = UIButton(configuration: config)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        return view
    }()
    
    // MARK: Object cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setup() {
        selectionStyle = .none
        
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        
        [iconImageView, badgeButton, titleLabel, subtitleLabel, metricTextView].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            badgeButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            badgeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            metricTextView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            metricTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            metricTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            metricTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Configure
    
    func configure(with recommendedGoal: DisplayedRecommendedGoal) {
        iconImageView.image = UIImage(systemName: recommendedGoal.icon)
        
        titleLabel.attributedText = .withLetterSpacing(
            text: recommendedGoal.title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        subtitleLabel.attributedText = .withLetterSpacing(
            text: recommendedGoal.subTitle,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )

        metricTextView.configure(metrics: [
            ("달성 회차", recommendedGoal.count),
            ("권장 러닝 시간", recommendedGoal.time),
            ("권장 페이스", recommendedGoal.pace)
        ])
        
        badgeButton.isHidden = !recommendedGoal.isRecommended
        
        container.layer.borderColor = recommendedGoal.isSelected ? UIColor(hex: 0x3E4FFF).cgColor : UIColor(hex: 0xDFE4EC).cgColor
    }
}

final class MetricTextView: UIView {
    
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

    private var metricViews: [MetricTextItemView] = []

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
    
    func configure(metrics: [(title: String, value: String)]) {
        metricsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricViews.removeAll()
        
        var firstMetricView: MetricTextItemView?
        for (index, metric) in metrics.enumerated() {
            let metricView = MetricTextItemView()
            metricView.configure(title: metric.title, value: metric.value)
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
                    separator.heightAnchor.constraint(equalToConstant: 20)
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

final class MetricTextItemView: UIView {
    
    // MARK: UI

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
        [valueLabel, titleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: Configure
    
    func configure(title: String, value: String) {
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
