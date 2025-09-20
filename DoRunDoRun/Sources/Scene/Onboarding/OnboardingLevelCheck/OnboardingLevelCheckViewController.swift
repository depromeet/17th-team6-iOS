//
//  OnboardingLevelCheckViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckDisplayLogic: AnyObject {
}

final class OnboardingLevelCheckViewController: UIViewController {
    var interactor: OnboardingLevelCheckBusinessLogic?
    var router: (OnboardingLevelCheckRoutingLogic & OnboardingLevelCheckDataPassing)?
    
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
}

extension OnboardingLevelCheckViewController: OnboardingLevelCheckDisplayLogic {
}
