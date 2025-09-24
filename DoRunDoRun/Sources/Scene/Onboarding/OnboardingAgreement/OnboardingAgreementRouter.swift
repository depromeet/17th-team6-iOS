//
//  OnboardingAgreementRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingAgreementRoutingLogic {
    func routeToRunningLevelCheck()
}

protocol OnboardingAgreementDataPassing {
    var dataStore: OnboardingAgreementDataStore? { get }
}

final class OnboardingAgreementRouter: OnboardingAgreementRoutingLogic, OnboardingAgreementDataPassing {
    weak var viewController: OnboardingAgreementViewController?
    var dataStore: OnboardingAgreementDataStore?
    
    // MARK: Routing
    func routeToRunningLevelCheck() {
        let destinationVC = RunningLevelCheckViewController()
        var destinationDS = destinationVC.router!.dataStore!
        passDataToRunningLevelCheck(&destinationDS, frome: dataStore!)
        navigateToRunningLevelCheck(destinationVC, from: viewController!)
    }
    
    // MARK: Navigation
    private func navigateToRunningLevelCheck(
        _ destination: RunningLevelCheckViewController,
        from source: OnboardingAgreementViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToRunningLevelCheck(
        _ destination: inout RunningLevelCheckDataStore,
        frome source: OnboardingAgreementDataStore
    ) {
        // 데이터 전달
    }
}
