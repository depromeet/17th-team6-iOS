//
//  OnboardingPermissionInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingPermissionBusinessLogic {
}

protocol OnboardingPermissionDataStore {
    //var name: String { get set }
}

final class OnboardingPermissionInteractor: OnboardingPermissionDataStore {
    var presenter: OnboardingPermissionPresentationLogic?
    //var name: String = ""
    
    // MARK: Do something
    
}

extension OnboardingPermissionInteractor: OnboardingPermissionBusinessLogic {
}
