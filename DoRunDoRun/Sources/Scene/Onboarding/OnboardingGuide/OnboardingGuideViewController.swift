//
//  OnboardingGuideViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGuideDisplayLogic: AnyObject {
}

final class OnboardingGuideViewController: UIViewController {
    var interactor: OnboardingGuideBusinessLogic?
    var router: (OnboardingGuideRoutingLogic & OnboardingGuideDataPassing)?
    
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
        let interactor = OnboardingGuideInteractor()
        let presenter = OnboardingGuidePresenter()
        let router = OnboardingGuideRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}

extension OnboardingGuideViewController: OnboardingGuideDisplayLogic {
}
