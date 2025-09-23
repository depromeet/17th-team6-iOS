//
//  OnboardingLevelCheckRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckRoutingLogic {
    func routeToGoalSetting()
}

protocol OnboardingLevelCheckDataPassing {
    var dataStore: OnboardingLevelCheckDataStore? { get }
}

final class OnboardingLevelCheckRouter: OnboardingLevelCheckRoutingLogic, OnboardingLevelCheckDataPassing {
    weak var viewController: OnboardingLevelCheckViewController?
    var dataStore: OnboardingLevelCheckDataStore?
    
    // MARK: Routing
    func routeToGoalSetting() {
        let destinationVC = OnboardingGoalSettingViewController()
        var destinationDS = destinationVC.router!.dataStore!
        passDataToOverallGoalList(&destinationDS, frome: dataStore!)
        navigateToOverallGoalList(destinationVC, from: viewController!)
    }
    
    // MARK: Navigation
    private func navigateToOverallGoalList(
        _ destination: OnboardingGoalSettingViewController,
        from source: OnboardingLevelCheckViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToOverallGoalList(
        _ destination: inout OnboardingGoalSettingDataStore,
        frome source: OnboardingLevelCheckDataStore
    ) {
        // 데이터 전달
    }
}
