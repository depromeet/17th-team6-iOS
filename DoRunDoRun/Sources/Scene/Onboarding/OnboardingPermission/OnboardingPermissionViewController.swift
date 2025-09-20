//
//  OnboardingPermissionViewController.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingPermissionDisplayLogic: AnyObject {
}

final class OnboardingPermissionViewController: UIViewController {
    var interactor: OnboardingPermissionBusinessLogic?
    var router: (OnboardingPermissionRoutingLogic & OnboardingPermissionDataPassing)?
    
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
}

extension OnboardingPermissionViewController: OnboardingPermissionDisplayLogic {
}
