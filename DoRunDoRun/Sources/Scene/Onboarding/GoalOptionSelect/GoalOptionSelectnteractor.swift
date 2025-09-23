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
        GoalOption(image: "flag", title: "마라톤에 도전할래요", subtitle: "10km · 21km · 42km"),
        GoalOption(image: "dumbbell", title: "체력을 키울래요", subtitle: "30분 달리기"),
        GoalOption(image: "heart", title: "지구력을 키울래요", subtitle: "Zone2 러닝")
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
