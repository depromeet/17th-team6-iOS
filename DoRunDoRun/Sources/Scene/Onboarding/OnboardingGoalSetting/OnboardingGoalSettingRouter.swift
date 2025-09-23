//
//  OnboardingGoalSettingRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGoalSettingRoutingLogic {
    func routeToGuide()
}

protocol OnboardingGoalSettingDataPassing {
    var dataStore: OnboardingGoalSettingDataStore? { get }
}

final class OnboardingGoalSettingRouter: OnboardingGoalSettingRoutingLogic, OnboardingGoalSettingDataPassing {
    weak var viewController: OnboardingGoalSettingViewController?
    var dataStore: OnboardingGoalSettingDataStore?
    
    // MARK: Routing
    func routeToGuide() {
        let destinationVC = OnboardingGuideViewController()
        var destinationDS = destinationVC.router!.dataStore!
        passDataToGuide(&destinationDS, frome: dataStore!)
        navigateToGuide(destinationVC, from: viewController!)
    }
    
    // MARK: Navigation
    private func navigateToGuide(
        _ destination: OnboardingGuideViewController,
        from source: OnboardingGoalSettingViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToGuide(
        _ destination: inout OnboardingGuideDataStore,
        frome source: OnboardingGoalSettingDataStore
    ) {
        destination.selectedGoalOption = source.selectedGoalOption
    }
}
