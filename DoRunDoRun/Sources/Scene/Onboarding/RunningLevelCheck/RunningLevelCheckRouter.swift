//
//  RunningLevelCheckRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RunningLevelCheckRoutingLogic {
    func routeToGoalSetting()
}

protocol RunningLevelCheckDataPassing {
    var dataStore: RunningLevelCheckDataStore? { get }
}

final class RunningLevelCheckRouter: RunningLevelCheckRoutingLogic, RunningLevelCheckDataPassing {
    weak var viewController: RunningLevelCheckViewController?
    var dataStore: RunningLevelCheckDataStore?
    
    // MARK: Routing
    func routeToGoalSetting() {
        let destinationVC = GoalOptionSelectViewController()
        var destinationDS = destinationVC.router!.dataStore!
        passDataToGoalSetting(&destinationDS, frome: dataStore!)
        navigateToGoalSetting(destinationVC, from: viewController!)
    }
    
    // MARK: Navigation
    private func navigateToGoalSetting(
        _ destination: GoalOptionSelectViewController,
        from source: RunningLevelCheckViewController
    ) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: Passing data
    private func passDataToGoalSetting(
        _ destination: inout GoalOptionSelectDataStore,
        frome source: RunningLevelCheckDataStore
    ) {
        // 데이터 전달
    }
}
