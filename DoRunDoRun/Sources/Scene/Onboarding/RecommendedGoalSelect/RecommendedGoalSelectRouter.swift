//
//  RecommendedGoalSelectRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RecommendedGoalSelectRoutingLogic {
}

protocol RecommendedGoalSelectDataPassing {
    var dataStore: RecommendedGoalSelectDataStore? { get }
}

final class RecommendedGoalSelectRouter: RecommendedGoalSelectRoutingLogic, RecommendedGoalSelectDataPassing {
    weak var viewController: RecommendedGoalSelectViewController?
    var dataStore: RecommendedGoalSelectDataStore?
}
