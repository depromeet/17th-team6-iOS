//
//  RunningLevelCheckRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RunningLevelCheckRoutingLogic {
    func routeToGoalOptionSelect()
}

protocol RunningLevelCheckDataPassing {
    var dataStore: RunningLevelCheckDataStore? { get }
}

final class RunningLevelCheckRouter: RunningLevelCheckRoutingLogic, RunningLevelCheckDataPassing {
    weak var viewController: RunningLevelCheckViewController?
    var dataStore: RunningLevelCheckDataStore?
    
    // MARK: Routing
    func routeToGoalOptionSelect() {
        let destinationVC = GoalOptionSelectViewController()
        var destinationDS = destinationVC.router!.dataStore!
        passDataToGoalOptionSelect(&destinationDS, frome: dataStore!)
        navigateToGoalOptionSelect(destinationVC, from: viewController!)
    }
    
    // MARK: Navigation
    private func navigateToGoalOptionSelect(
        _ destination: GoalOptionSelectViewController,
        from source: RunningLevelCheckViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToGoalOptionSelect(
        _ destination: inout GoalOptionSelectDataStore,
        frome source: RunningLevelCheckDataStore
    ) {
        // 데이터 전달
    }
}
