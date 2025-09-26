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
    func displayStart(viewModel: RecommendedGoalSelect.Start.ViewModel)
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
        interactor?.startWithGoal(request: .init())
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
    
    func displayStart(viewModel: RecommendedGoalSelect.Start.ViewModel) {
        // 온보딩 완료 상태로 전환
        Defaults.hasSeenOnboarding = true

        // 전환할 메인 탭
        let main = MainTabViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {

            UIView.transition(
                with: window,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = main
                },
                completion: nil
            )
        }
    }
}
