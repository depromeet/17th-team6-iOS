//
//  GoalOptionSelectModels.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

enum GoalOptionSelect {
    // MARK: Use cases

    enum LoadGoalOptions {
        struct Request {}
        struct Response {
            let goalOptions: [GoalOption]
            let selectedIndex: Int
        }
        struct ViewModel {
            let displayedGoalOptions: [DisplayedGoalOption]
        }
    }

    enum SelectGoalOption {
        struct Request { let index: Int }
        struct Response {
            let goalOptions: [GoalOption]
            let selectedIndex: Int
            let previousIndex: Int
        }
        struct ViewModel {
            let displayedGoalOptions: [DisplayedGoalOption]
            let selectedIndex: Int
            let previousIndex: Int
        }
    }
}

struct DisplayedGoalOption {
    let image: String
    let title: String
    let subtitle: String
    let isSelected: Bool
}
