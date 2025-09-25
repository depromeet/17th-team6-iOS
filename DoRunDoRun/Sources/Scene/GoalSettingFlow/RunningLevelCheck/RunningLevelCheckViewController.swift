//
//  RunningLevelCheckViewController.swift
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

protocol RunningLevelCheckDisplayLogic: AnyObject {
    func displayRunningLevels(viewModel: RunningLevelCheck.LoadRunningLevels.ViewModel)
    func displaySelectedRunningLevel(viewModel: RunningLevelCheck.SelectRunningLevel.ViewModel)
}

final class RunningLevelCheckViewController: UIViewController {
    var interactor: RunningLevelCheckBusinessLogic?
    var router: (RunningLevelCheckRoutingLogic & RunningLevelCheckDataPassing)?
    
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
        setupActions()
        
        interactor?.loadRunningLevels(request: .init())
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = RunningLevelCheckInteractor()
        let presenter = RunningLevelCheckPresenter()
        let router = RunningLevelCheckRouter()
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
        tableView.register(RunningLevelCell.self, forCellReuseIdentifier: RunningLevelCell.identifier)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setupActions() {
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc private func didTapNext() {
        router?.routeToGoalOptionSelect()
    }
}

extension RunningLevelCheckViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedLevels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RunningLevelCell.identifier, for: indexPath) as? RunningLevelCell else {
            return UITableViewCell()
        }
        let runningLevel = displayedLevels[indexPath.row]
        cell.configure(with: runningLevel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.selectRunningLevel(request: .init(index: indexPath.row))
    }
}

extension RunningLevelCheckViewController: RunningLevelCheckDisplayLogic {
    func displayRunningLevels(viewModel: RunningLevelCheck.LoadRunningLevels.ViewModel) {
        displayedLevels = viewModel.displayedRunningLevels
        tableView.reloadData()
    }
    
    func displaySelectedRunningLevel(viewModel: RunningLevelCheck.SelectRunningLevel.ViewModel) {
        displayedLevels = viewModel.displayedLevels
        let indexPaths = [
            IndexPath(row: viewModel.previousIndex, section: 0),
            IndexPath(row: viewModel.selectedIndex, section: 0)
        ]
        tableView.reloadRows(at: indexPaths, with: .none)
    }
}
