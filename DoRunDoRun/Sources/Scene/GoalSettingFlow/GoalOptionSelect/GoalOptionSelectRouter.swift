//
//  GoalOptionSelectRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol GoalOptionSelectRoutingLogic {
    func routeToRecommendedGoalSelect()
}

protocol GoalOptionSelectDataPassing {
    var dataStore: GoalOptionSelectDataStore? { get }
}

final class GoalOptionSelectRouter: GoalOptionSelectRoutingLogic, GoalOptionSelectDataPassing {
    weak var viewController: GoalOptionSelectViewController?
    var dataStore: GoalOptionSelectDataStore?
    
    // MARK: Routing
    func routeToRecommendedGoalSelect() {
        let destinationVC = RecommendedGoalSelectViewController()
        var destinationDS = destinationVC.router!.dataStore!
        passDataToRecommendedGoalSelect(&destinationDS, frome: dataStore!)
        navigateToRecommendedGoalSelect(destinationVC, from: viewController!)
    }
    
    // MARK: Navigation
    private func navigateToRecommendedGoalSelect(
        _ destination: RecommendedGoalSelectViewController,
        from source: GoalOptionSelectViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToRecommendedGoalSelect(
        _ destination: inout RecommendedGoalSelectDataStore,
        frome source: GoalOptionSelectDataStore
    ) {
        destination.selectedGoalOption = source.selectedGoalOption
    }
}
