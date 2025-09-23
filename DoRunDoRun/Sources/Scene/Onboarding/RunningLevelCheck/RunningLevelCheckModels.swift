//
//  RunningLevelCheckModels.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

enum RunningLevelCheck {
    // MARK: Use cases
    enum LoadRunningLevels {
        struct Request {}
        struct Response {
            let runningLevels: [RunningLevel]
            let selectedIndex: Int
        }
        struct ViewModel {
            let displayedRunningLevels: [DisplayedRunningLevel]
        }
    }
    
    enum SelectRunningLevel {
        struct Request { let index: Int }
        struct Response {
            let runningLevels: [RunningLevel]
            let selectedIndex: Int
            let previousIndex: Int
        }
        struct ViewModel {
            let displayedLevels: [DisplayedRunningLevel]
            let selectedIndex: Int
            let previousIndex: Int
        }
    }
}

struct DisplayedRunningLevel {
    let image: String
    let title: String
    let subtitle: String
    let isSelected: Bool
}
