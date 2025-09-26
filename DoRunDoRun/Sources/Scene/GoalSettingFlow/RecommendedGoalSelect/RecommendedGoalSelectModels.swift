//
//  RecommendedGoalSelectModels.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

enum RecommendedGoalSelect {
    // MARK: Use cases
    
    enum LoadRecommendedGoals {
        struct Request {}
        struct Response {
            let recommendedGoals: [RecommendedGoal]
            let selectedIndex: Int
        }
        struct ViewModel {
            let displayedRecommendedGoals: [DisplayedRecommendedGoal]
        }
    }
    
    enum SelectRecommendedGoal {
        struct Request { let index: Int }
        struct Response {
            let goals: [RecommendedGoal]
            let selectedIndex: Int
            let previousIndex: Int
        }
        struct ViewModel {
            let displayedGoals: [DisplayedRecommendedGoal]
            let selectedIndex: Int
            let previousIndex: Int
        }
    }
    
    enum Start {
        struct Request {}
        struct Response {
            let overallGoal: OverallGoal
        }
        struct ViewModel {}
    }
}

struct DisplayedRecommendedGoal {
    let icon: String
    let title: String
    let subTitle: String
    let count: String
    let time: String
    let pace: String
    let isRecommended: Bool
    let isSelected: Bool
}
