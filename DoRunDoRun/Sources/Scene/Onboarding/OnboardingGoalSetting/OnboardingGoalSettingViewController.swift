//
//  OnboardingGoalSettingViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGoalSettingDisplayLogic: AnyObject {
}

final class OnboardingGoalSettingViewController: UIViewController {
    var interactor: OnboardingGoalSettingBusinessLogic?
    var router: (OnboardingGoalSettingRoutingLogic & OnboardingGoalSettingDataPassing)?
    
    // MARK: Object lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = OnboardingGoalSettingInteractor()
        let presenter = OnboardingGoalSettingPresenter()
        let router = OnboardingGoalSettingRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}

extension OnboardingGoalSettingViewController: OnboardingGoalSettingDisplayLogic {
}
