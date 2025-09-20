//
//  OnboardingGoalSettingInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGoalSettingBusinessLogic {
}

protocol OnboardingGoalSettingDataStore {
    //var name: String { get set }
}

final class OnboardingGoalSettingInteractor: OnboardingGoalSettingDataStore {
    var presenter: OnboardingGoalSettingPresentationLogic?
    //var name: String = ""
    
    // MARK: Do something
    
}

extension OnboardingGoalSettingInteractor: OnboardingGoalSettingBusinessLogic {
}
