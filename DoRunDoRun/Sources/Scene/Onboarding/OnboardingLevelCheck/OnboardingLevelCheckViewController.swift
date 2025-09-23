//
//  OnboardingLevelCheckViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

struct RunningLevel {
    let image: String
    let title: String
    let subtitle: String
}

protocol OnboardingLevelCheckDisplayLogic: AnyObject {
    func displayRunningLevels(viewModel: OnboardingLevelCheck.LoadRunningLevels.ViewModel)
    func displaySelectedRunningLevel(viewModel: OnboardingLevelCheck.SelectRunningLevel.ViewModel)
}

final class OnboardingLevelCheckViewController: UIViewController {
    var interactor: OnboardingLevelCheckBusinessLogic?
    var router: (OnboardingLevelCheckRoutingLogic & OnboardingLevelCheckDataPassing)?
    
    // MARK: UI
    
    private let currentPageLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "2",
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
            text: "평소 러닝 수준을 알려주세요.",
            font: .pretendard(size: 24, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
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
        
    private var displayedLevels: [DisplayedRunningLevel] = []
    
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
        
        interactor?.loadRunningLevels(request: .init())
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = OnboardingLevelCheckInteractor()
        let presenter = OnboardingLevelCheckPresenter()
        let router = OnboardingLevelCheckRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
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
        tableView.register(RunningLevelCell.self, forCellReuseIdentifier: RunningLevelCell.identifier)
        tableView.isScrollEnabled = false
    }
}

extension OnboardingLevelCheckViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedLevels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RunningLevelCell.identifier, for: indexPath) as? RunningLevelCell else {
            return UITableViewCell()
        }
        let level = displayedLevels[indexPath.row]
        cell.configure(
            imageName: level.image,
            title: level.title,
            subtitle: level.subtitle,
            isSelected: level.isSelected
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.selectRunningLevel(request: .init(index: indexPath.row))
    }
}

extension OnboardingLevelCheckViewController: OnboardingLevelCheckDisplayLogic {
    func displayRunningLevels(viewModel: OnboardingLevelCheck.LoadRunningLevels.ViewModel) {
        displayedLevels = viewModel.displayedRunningLevels
        tableView.reloadData()
    }
    
    func displaySelectedRunningLevel(viewModel: OnboardingLevelCheck.SelectRunningLevel.ViewModel) {
        displayedLevels = viewModel.displayedLevels
        let indexPaths = [
            IndexPath(row: viewModel.previousIndex, section: 0),
            IndexPath(row: viewModel.selectedIndex, section: 0)
        ]
        tableView.reloadRows(at: indexPaths, with: .none)
    }
}

// MARK: - RunningLevel

final class RunningLevelCell: UITableViewCell {
    static let identifier = "RunningLevelCell"
    
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
    
    func configure(imageName: String, title: String, subtitle: String, isSelected: Bool) {
        iconView.image = UIImage(systemName: imageName)

        titleLabel.attributedText = .withLetterSpacing(
            text: title,
            font: .pretendard(size: 18, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        
        subtitleLabel.attributedText = .withLetterSpacing(
            text: subtitle,
            font: .pretendard(size: 14, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        
        container.layer.borderColor = isSelected ? UIColor(hex: 0x3E4FFF).cgColor : UIColor(hex: 0xDFE4EC).cgColor
    }
}
