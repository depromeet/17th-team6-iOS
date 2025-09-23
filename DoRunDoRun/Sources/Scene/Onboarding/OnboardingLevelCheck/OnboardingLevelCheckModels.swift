//
//  OnboardingLevelCheckModels.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

enum OnboardingLevelCheck {
    // MARK: Use cases
    enum LoadLevels {
        struct Request {}
        struct Response {
            let levels: [RunningLevel]
            let selectedIndex: Int
        }
        struct ViewModel {
            let displayedLevels: [DisplayedLevel]
        }
    }
    
    enum SelectLevel {
        struct Request { let index: Int }
        struct Response {
            let levels: [RunningLevel]
            let selectedIndex: Int
            let previousIndex: Int
        }
        struct ViewModel {
            let displayedLevels: [DisplayedLevel]
            let selectedIndex: Int
            let previousIndex: Int
        }
    }
}

struct DisplayedLevel {
    let image: String
    let title: String
    let subtitle: String
    let isSelected: Bool
}
