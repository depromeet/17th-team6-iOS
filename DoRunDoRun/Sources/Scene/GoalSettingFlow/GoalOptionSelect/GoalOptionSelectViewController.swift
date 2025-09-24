//
//  GoalOptionSelectViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol GoalOptionSelectDisplayLogic: AnyObject {
    func displayGoalOptions(viewModel: GoalOptionSelect.LoadGoalOptions.ViewModel)
    func displaySelectedGoalOption(viewModel: GoalOptionSelect.SelectGoalOption.ViewModel)
}

final class GoalOptionSelectViewController: UIViewController {
    var interactor: GoalOptionSelectBusinessLogic?
    var router: (GoalOptionSelectRoutingLogic & GoalOptionSelectDataPassing)?
    
    // MARK: UI
    
    private let currentPageLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "3",
            font: .pretendard(size: 14, weight: .medium),
            px: -0.2,
            color: .init(hex: 0x3E4FFF)
        )
        return label
    }()
    
    private let totalPageLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "/3",
            font: .pretendard(size: 14, weight: .medium),
            px: -0.2,
            color: .init(hex: 0x8F949C)
        )
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "도전하고 싶은 목표가 있나요?",
            font: .pretendard(size: 24, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        return label
    }()
    
    private let tableView = UITableView()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let attributedTitle = NSAttributedString.withLetterSpacing(
            text: "다음",
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

    private var displayedGoalOptions: [DisplayedGoalOption] = []
    
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
        
        interactor?.loadGoalOptions(request: .init())
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = GoalOptionSelectInteractor()
        let presenter = GoalOptionSelectPresenter()
        let router = GoalOptionSelectRouter()
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
        
        [currentPageLabel, totalPageLabel, titleLabel, tableView, nextButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            currentPageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            currentPageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            totalPageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            totalPageLabel.leadingAnchor.constraint(equalTo: currentPageLabel.trailingAnchor, constant: 0),
            
            titleLabel.topAnchor.constraint(equalTo: totalPageLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -12),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChallengeGoalCell.self, forCellReuseIdentifier: ChallengeGoalCell.identifier)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setupActions() {
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc private func didTapNext() {
        router?.routeToGuide()
    }
}

extension GoalOptionSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedGoalOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChallengeGoalCell.identifier, for: indexPath) as? ChallengeGoalCell else {
            return UITableViewCell()
        }
        let goalOption = displayedGoalOptions[indexPath.row]
        cell.configure(with: goalOption)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.selectGoalOption(request: .init(index: indexPath.row))
    }
}

extension GoalOptionSelectViewController: GoalOptionSelectDisplayLogic {
    func displayGoalOptions(viewModel: GoalOptionSelect.LoadGoalOptions.ViewModel) {
        displayedGoalOptions = viewModel.displayedGoalOptions
        tableView.reloadData()
    }

    func displaySelectedGoalOption(viewModel: GoalOptionSelect.SelectGoalOption.ViewModel) {
        displayedGoalOptions = viewModel.displayedGoalOptions
        let indexPaths = [
            IndexPath(row: viewModel.previousIndex, section: 0),
            IndexPath(row: viewModel.selectedIndex, section: 0)
        ]
        tableView.reloadRows(at: indexPaths, with: .none)
    }
}


// MARK: - ChallengeGoalCell

final class ChallengeGoalCell: UITableViewCell {
    static let identifier = "ChallengeGoalCell"
    
    // MARK: UI
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        return view
    }()
    
    // MARK: Object lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        selectionStyle = .none
        
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        [iconView, titleLabel, subtitleLabel].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 46),
            iconView.heightAnchor.constraint(equalToConstant: 46),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: Configure
    
    func configure(with goalOption: DisplayedGoalOption) {
        iconView.image = UIImage(systemName: goalOption.image)

        titleLabel.attributedText = .withLetterSpacing(
            text: goalOption.title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        subtitleLabel.attributedText = .withLetterSpacing(
            text: goalOption.subtitle,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        
        container.layer.borderColor = goalOption.isSelected ? UIColor(hex: 0x3E4FFF).cgColor : UIColor(hex: 0xDFE4EC).cgColor
    }
}
