//
//  GoalOptionSelectInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol GoalOptionSelectBusinessLogic {
    func loadGoalOptions(request: GoalOptionSelect.LoadGoalOptions.Request)
    func selectGoalOption(request: GoalOptionSelect.SelectGoalOption.Request)
}

protocol GoalOptionSelectDataStore {
    var goalOptions: [GoalOption] { get set }
    var selectedGoalOption: GoalOption? { get set }
    var selectedIndex: Int { get set }
}

final class GoalOptionSelectInteractor: GoalOptionSelectDataStore {
    var presenter: GoalOptionSelectPresentationLogic?
    var goalOptions: [GoalOption] = [
        GoalOption(
            type: .marathon,
            distance: [10000, 21000, 42000],
            duration: [],
            pace: []
        ),
        GoalOption(
            type: .stamina,
            distance: [],
            duration: [30],
            pace: []
        ),
        GoalOption(
            type: .zone2,
            distance: [5000, 10000, 15000],
            duration: [40, 80, 120],
            pace: [360, 420]
        )
    ]
    var selectedGoalOption: GoalOption?
    var selectedIndex: Int = 0
}

extension GoalOptionSelectInteractor: GoalOptionSelectBusinessLogic {
    func loadGoalOptions(request: GoalOptionSelect.LoadGoalOptions.Request) {
        if selectedGoalOption == nil {
            selectedGoalOption = goalOptions[selectedIndex]
        }
        
        presenter?.presentGoalOptions(
            response: .init(goalOptions: goalOptions, selectedIndex: selectedIndex)
        )
    }

    func selectGoalOption(request: GoalOptionSelect.SelectGoalOption.Request) {
        let previousIndex = selectedIndex
        selectedIndex = request.index
        selectedGoalOption = goalOptions[selectedIndex]
        
        presenter?.presentSelectedGoalOption(
            response: .init(goalOptions: goalOptions, selectedIndex: selectedIndex, previousIndex: previousIndex)
        )
    }
}
