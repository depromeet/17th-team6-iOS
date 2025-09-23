//
//  OnboardingPermissionRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingPermissionRoutingLogic {
    func routeToLevelCheck()
}

protocol OnboardingPermissionDataPassing {
    var dataStore: OnboardingPermissionDataStore? { get }
}

final class OnboardingPermissionRouter: OnboardingPermissionRoutingLogic, OnboardingPermissionDataPassing {
    weak var viewController: OnboardingPermissionViewController?
    var dataStore: OnboardingPermissionDataStore?
    
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
        from source: OnboardingPermissionViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToLevelCheck(
        _ destination: inout RunningLevelCheckDataStore,
        frome source: OnboardingPermissionDataStore
    ) {
        // 데이터 전달
    }
}
