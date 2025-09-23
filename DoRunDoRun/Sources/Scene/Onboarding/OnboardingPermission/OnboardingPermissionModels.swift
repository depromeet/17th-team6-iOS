//
//  OnboardingPermissionModels.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

enum OnboardingPermission {
    // MARK: Use cases
    
    enum LoadAgreements {
        struct Request {}
        struct Response {
            let agreements: [Agreement]
        }
        struct ViewModel {
            let displayedAgreements: [DisplayedAgreement]
        }
    }
    
    enum ToggleAll {
        struct Request {}
        struct Response { let agreements: [Agreement] }
        struct ViewModel {
            let displayedAgreements: [DisplayedAgreement]
            let isAllChecked: Bool
            let isNextEnabled: Bool
        }
    }

    enum ToggleOne {
        struct Request { let index: Int }
        struct Response {
            let agreements: [Agreement]
            let index: Int
        }
        struct ViewModel {
            let displayedAgreement: DisplayedAgreement
            let index: Int
            let isAllChecked: Bool
            let isNextEnabled: Bool
        }
    }
}

struct DisplayedAgreement {
    let title: String
    let isChecked: Bool
}
