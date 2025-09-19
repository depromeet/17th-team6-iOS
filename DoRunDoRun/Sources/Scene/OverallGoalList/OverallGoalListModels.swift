//
//  OverallGoalListModels.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

enum OverallGoalList {
    
    // MARK: - Use cases
    enum GetOverallGoal {
        struct Request { }
        struct Response {
            let overallGoal: OverallGoal
        }
        struct ViewModel {
            struct DisplayedOverallGoal {
                let iconName: String
                let title: String
                let currentSession: String
                let totalSession: String
                let progress: Float
            }
            let displayedOverallGoal: DisplayedOverallGoal
        }
    }
    
    enum LoadSessionGoals {
        struct Request { }
        struct Response {
            let sessionGoals: [SessionGoal]
        }
        struct ViewModel {
            struct DisplayedSessionGoal {
                let round: String
                let distance: String
                let time: String
                let pace: String
                let isCompleted: Bool
            }
            let displayedSessionGoals: [DisplayedSessionGoal]
        }
    }
}
