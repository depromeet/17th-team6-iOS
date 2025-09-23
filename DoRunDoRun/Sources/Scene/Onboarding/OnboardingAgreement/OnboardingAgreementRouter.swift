//
//  OnboardingAgreementRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingAgreementRoutingLogic {
    func routeToLevelCheck()
}

protocol OnboardingAgreementDataPassing {
    var dataStore: OnboardingAgreementDataStore? { get }
}

final class OnboardingAgreementRouter: OnboardingAgreementRoutingLogic, OnboardingAgreementDataPassing {
    weak var viewController: OnboardingAgreementViewController?
    var dataStore: OnboardingAgreementDataStore?
    
    // MARK: Routing
    func routeToLevelCheck() {
        let destinationVC = RunningLevelCheckViewController()
        var destinationDS = destinationVC.router!.dataStore!
        passDataToLevelCheck(&destinationDS, frome: dataStore!)
        navigateToLevelCheck(destinationVC, from: viewController!)
    }
    
    // MARK: Navigation
    private func navigateToLevelCheck(
        _ destination: RunningLevelCheckViewController,
        from source: OnboardingAgreementViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToLevelCheck(
        _ destination: inout RunningLevelCheckDataStore,
        frome source: OnboardingAgreementDataStore
    ) {
        // 데이터 전달
    }
}
