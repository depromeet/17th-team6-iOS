//
//  OverallGoalListViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListDisplayLogic: AnyObject {
    func displayOverallGoal(viewModel: OverallGoalList.GetOverallGoal.ViewModel)
    func displaySessionGoals(viewModel: OverallGoalList.LoadSessionGoals.ViewModel)
    func displaySelectedSessionGoal(viewModel: OverallGoalList.SelectSessionGoal.ViewModel)
}

final class OverallGoalListViewController: UIViewController {
    var interactor: OverallGoalListBusinessLogic?
    var router: (OverallGoalListRoutingLogic & OverallGoalListDataPassing)?
    
    // MARK: UI
    
    private let headerView = GoalHeaderView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: Properties
    
    private var displayedSessionGoals: [DisplayedSessionGoal] = []
    
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
        
        fetchGoalData()
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
        navigationItem.title = "목표 목록"
        navigationController?.navigationBar.tintColor = .init(hex: 0x1C1B1F)
    }
    
    private func setupView() {
        view.backgroundColor = .init(hex: 0xFFFFFF)
        
        [headerView, tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
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
    }
    
    // MARK: Action
    
    private func fetchGoalData() {
        interactor?.getOverallGoal(request: OverallGoalList.GetOverallGoal.Request())
        interactor?.loadSessionGoals(request: OverallGoalList.LoadSessionGoals.Request())
    }
}

extension OverallGoalListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedSessionGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GoalSessionCell.identifier, for: indexPath) as? GoalSessionCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let session = displayedSessionGoals[indexPath.row]
        cell.configure(with: session)
        cell.showRetryButton(session.isCompleted && session.isExpanded)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let session = displayedSessionGoals[indexPath.row]
        return (session.isCompleted && session.isExpanded) ? 162 : 86
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.selectSessionGoal(request: .init(index: indexPath.row))
    }
}

extension OverallGoalListViewController: OverallGoalListDisplayLogic {
    func displayOverallGoal(viewModel: OverallGoalList.GetOverallGoal.ViewModel) {
        let displayed = viewModel.displayedOverallGoal
        headerView.configure(with: displayed)
    }
    
    func displaySessionGoals(viewModel: OverallGoalList.LoadSessionGoals.ViewModel) {
        displayedSessionGoals = viewModel.displayedSessionGoals
        tableView.reloadData()
    }
    
    func displaySelectedSessionGoal(viewModel: OverallGoalList.SelectSessionGoal.ViewModel) {
        if let error = viewModel.errorMessage {
            showToast(message: error, style: .error)
            return
        }

        displayedSessionGoals = viewModel.displayedSessionGoals

        var indexPaths: [IndexPath] = []
        if let prev = viewModel.previousIndex {
            indexPaths.append(IndexPath(row: prev, section: 0))
        }
        if let curr = viewModel.selectedIndex {
            indexPaths.append(IndexPath(row: curr, section: 0))
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }
}


// MARK: - Extensions (임시)
//
// 아래 익스텐션들은 원래 별도의 파일로 분리되어야 함.
// 충돌 방지를 위해 현재는 ViewController 파일에 임시로 두었음.
// 이후 정리 시에는 각각의 Extension 전용 파일로 이동 필요:
//
// - UIButton.Configuration+.swift
// - UIViewController+.swift
//

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
        let toast = InfoToastView(message: message, style: style)
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
