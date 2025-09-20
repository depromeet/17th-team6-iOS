//
//  OnboardingGuideRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGuideRoutingLogic {
}

protocol OnboardingGuideDataPassing {
    var dataStore: OnboardingGuideDataStore? { get }
}

final class OnboardingGuideRouter: OnboardingGuideRoutingLogic, OnboardingGuideDataPassing {
    weak var viewController: OnboardingGuideViewController?
    var dataStore: OnboardingGuideDataStore?
}
