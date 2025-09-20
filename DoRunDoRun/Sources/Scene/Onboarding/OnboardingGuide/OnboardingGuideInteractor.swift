//
//  OnboardingGuideInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGuideBusinessLogic {
}

protocol OnboardingGuideDataStore {
    //var name: String { get set }
}

final class OnboardingGuideInteractor: OnboardingGuideDataStore {
    var presenter: OnboardingGuidePresentationLogic?
    //var name: String = ""
    
    // MARK: Do something
    
}

extension OnboardingGuideInteractor: OnboardingGuideBusinessLogic {
}
