//
//  GoalOptionSelectRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol GoalOptionSelectRoutingLogic {
    func routeToGuide()
}

protocol GoalOptionSelectDataPassing {
    var dataStore: GoalOptionSelectDataStore? { get }
}

final class GoalOptionSelectRouter: GoalOptionSelectRoutingLogic, GoalOptionSelectDataPassing {
    weak var viewController: GoalOptionSelectViewController?
    var dataStore: GoalOptionSelectDataStore?
    
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
        from source: GoalOptionSelectViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToGuide(
        _ destination: inout OnboardingGuideDataStore,
        frome source: GoalOptionSelectDataStore
    ) {
        destination.selectedGoalOption = source.selectedGoalOption
    }
}
