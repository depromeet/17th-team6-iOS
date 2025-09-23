//
//  OnboardingPermissionViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

struct Agreement {
    let title: String
    let isRequired: Bool
    var isChecked: Bool
}

protocol OnboardingPermissionDisplayLogic: AnyObject {
    func displayAgreements(viewModel: OnboardingPermission.LoadAgreements.ViewModel)
    func displayToggleAll(viewModel: OnboardingPermission.ToggleAll.ViewModel)
    func displayToggleOne(viewModel: OnboardingPermission.ToggleOne.ViewModel)
}

final class OnboardingPermissionViewController: UIViewController {
    var interactor: OnboardingPermissionBusinessLogic?
    var router: (OnboardingPermissionRoutingLogic & OnboardingPermissionDataPassing)?
    
    // MARK: UI
    
    private let currentPageLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "1",
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
            text: "서비스 이용을 위해\n앱 권한을 허용해 주세요.",
            font: .pretendard(size: 24, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        label.numberOfLines = 2
        return label
    }()
        
    private let allCheckButton: UIButton = {
        let button = UIButton(configuration: .miniCheckmark(isChecked: false))
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let allCheckLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .withLetterSpacing(
            text: "약관 전체 동의",
            font: .pretendard(size: 16, weight: .bold),
            px: -0.2,
            color: .init(hex: 0x232529)
        )
        return label
    }()
    
    private let allCheckContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: 0xF0F3F8)
        return view
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
        button.isEnabled = false
        return button
    }()
    
    // MARK: Properties
    
    private var displayedAgreements: [DisplayedAgreement] = []

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
        
        interactor?.loadAgreements(request: .init())
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = OnboardingPermissionInteractor()
        let presenter = OnboardingPermissionPresenter()
        let router = OnboardingPermissionRouter()
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
        
        [currentPageLabel, totalPageLabel, titleLabel, allCheckContainer, dividerView, tableView, nextButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [allCheckButton, allCheckLabel].forEach {
            allCheckContainer.addSubview($0)
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
            
            allCheckContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            allCheckContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            allCheckContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            allCheckContainer.heightAnchor.constraint(equalToConstant: 32),
            
            allCheckButton.leadingAnchor.constraint(equalTo: allCheckContainer.leadingAnchor),
            allCheckButton.centerYAnchor.constraint(equalTo: allCheckContainer.centerYAnchor),
            allCheckButton.widthAnchor.constraint(equalToConstant: 32),
            allCheckButton.heightAnchor.constraint(equalToConstant: 32),
            
            allCheckLabel.leadingAnchor.constraint(equalTo: allCheckButton.trailingAnchor, constant: 8),
            allCheckLabel.centerYAnchor.constraint(equalTo: allCheckContainer.centerYAnchor),
            
            dividerView.topAnchor.constraint(equalTo: allCheckContainer.bottomAnchor, constant: 20),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            tableView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 12),
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
        tableView.register(AgrementCell.self, forCellReuseIdentifier: AgrementCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 32
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAllCheck))
        allCheckContainer.addGestureRecognizer(tapGesture)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc private func didTapAllCheck() {
        interactor?.toggleAll(request: .init())
    }
    
    @objc private func didTapNext() {
        router?.routeToLevelCheck()
    }
}

extension OnboardingPermissionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedAgreements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AgrementCell.identifier, for: indexPath) as? AgrementCell else {
            return UITableViewCell()
        }
        let agreement = displayedAgreements[indexPath.row]
        cell.configure(title: agreement.title, isChecked: agreement.isChecked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.toggleOne(request: .init(index: indexPath.row))
    }
}

extension OnboardingPermissionViewController: OnboardingPermissionDisplayLogic {
    func displayAgreements(viewModel: OnboardingPermission.LoadAgreements.ViewModel) {
        displayedAgreements = viewModel.displayedAgreements
        tableView.reloadData()
    }
    
    func displayToggleAll(viewModel: OnboardingPermission.ToggleAll.ViewModel) {
        displayedAgreements = viewModel.displayedAgreements
        allCheckButton.configuration = .miniCheckmark(isChecked: viewModel.isAllChecked)
        nextButton.isEnabled = viewModel.isNextEnabled
        tableView.reloadData()
    }
    
    func displayToggleOne(viewModel: OnboardingPermission.ToggleOne.ViewModel) {
        displayedAgreements[viewModel.index] = viewModel.displayedAgreement
        allCheckButton.configuration = .miniCheckmark(isChecked: viewModel.isAllChecked)
        nextButton.isEnabled = viewModel.isNextEnabled
        tableView.reloadRows(at: [IndexPath(row: viewModel.index, section: 0)], with: .automatic)
    }
}


// MARK: Agreement

final class AgrementCell: UITableViewCell {
    static let identifier = "RunningLevelCell"
    
    // MARK: UI
    
    private let checkButton: UIButton = {
        let button = UIButton(configuration: .miniCheckmark(isChecked: false))
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let titleLabel = UILabel()
    
    private let arrowButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .regular)
        config.image = UIImage(systemName: "chevron.forward", withConfiguration: imageConfig)
        config.imagePadding = 0
        config.baseForegroundColor = UIColor(hex: 0x585D64)
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let container: UIView = {
        let view = UIView()
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
        
        [checkButton, titleLabel, arrowButton].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            checkButton.topAnchor.constraint(equalTo: container.topAnchor),
            checkButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 32),
            checkButton.heightAnchor.constraint(equalToConstant: 32),
            checkButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            
            arrowButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            arrowButton.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            arrowButton.widthAnchor.constraint(equalToConstant: 32),
            arrowButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: Configure
    
    func configure(title: String, isChecked: Bool) {
        titleLabel.attributedText = .withLetterSpacing(
            text: title,
            font: .pretendard(size: 16, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        
        checkButton.configuration = .miniCheckmark(isChecked: isChecked)
    }
}

extension UIButton.Configuration {
    static func miniCheckmark(isChecked: Bool) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        config.imagePadding = 0
        
        if isChecked {
            config.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: imageConfig)
            config.baseForegroundColor = UIColor(hex: 0x3E4FFF)
        } else {
            config.image = UIImage(systemName: "checkmark.circle", withConfiguration: imageConfig)
            config.baseForegroundColor = UIColor(hex: 0xB5B9C0)
        }
        return config
    }
}
