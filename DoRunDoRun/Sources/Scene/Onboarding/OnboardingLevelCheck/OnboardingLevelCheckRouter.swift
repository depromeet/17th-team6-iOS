//
//  OnboardingLevelCheckRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckRoutingLogic {
}

protocol OnboardingLevelCheckDataPassing {
    var dataStore: OnboardingLevelCheckDataStore? { get }
}

final class OnboardingLevelCheckRouter: OnboardingLevelCheckRoutingLogic, OnboardingLevelCheckDataPassing {
    weak var viewController: OnboardingLevelCheckViewController?
    var dataStore: OnboardingLevelCheckDataStore?
}
