//
//  OnboardingGoalSettingRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGoalSettingRoutingLogic {
}

protocol OnboardingGoalSettingDataPassing {
    var dataStore: OnboardingGoalSettingDataStore? { get }
}

final class OnboardingGoalSettingRouter: OnboardingGoalSettingRoutingLogic, OnboardingGoalSettingDataPassing {
    weak var viewController: OnboardingGoalSettingViewController?
    var dataStore: OnboardingGoalSettingDataStore?
}
