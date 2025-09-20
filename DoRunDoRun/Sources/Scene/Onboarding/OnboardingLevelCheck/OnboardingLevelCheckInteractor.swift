//
//  OnboardingLevelCheckInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckBusinessLogic {
}

protocol OnboardingLevelCheckDataStore {
    //var name: String { get set }
}

final class OnboardingLevelCheckInteractor: OnboardingLevelCheckDataStore {
    var presenter: OnboardingLevelCheckPresentationLogic?
    //var name: String = ""
    
    // MARK: Do something
    
}

extension OnboardingLevelCheckInteractor: OnboardingLevelCheckBusinessLogic {
}
