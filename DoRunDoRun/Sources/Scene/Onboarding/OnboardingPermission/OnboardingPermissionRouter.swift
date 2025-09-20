//
//  OnboardingPermissionRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingPermissionRoutingLogic {
}

protocol OnboardingPermissionDataPassing {
    var dataStore: OnboardingPermissionDataStore? { get }
}

final class OnboardingPermissionRouter: OnboardingPermissionRoutingLogic, OnboardingPermissionDataPassing {
    weak var viewController: OnboardingPermissionViewController?
    var dataStore: OnboardingPermissionDataStore?
}
