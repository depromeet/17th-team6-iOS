//
//  GoalOptionSelectPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol GoalOptionSelectPresentationLogic {
    func presentGoalOptions(response: GoalOptionSelect.LoadGoalOptions.Response)
    func presentSelectedGoalOption(response: GoalOptionSelect.SelectGoalOption.Response)
}

final class GoalOptionSelectPresenter {
    weak var viewController: GoalOptionSelectDisplayLogic?
    
    // MARK: Mapper
    private func makeDisplayedGoalOption(from goal: GoalOption, isSelected: Bool) -> DisplayedGoalOption {
        switch goal.type {
        case .marathon:
            return DisplayedGoalOption(image: "flag", title: "마라톤에 도전할래요", subtitle: "10km · 21km · 42km", isSelected: isSelected)
        case .stamina:
            return DisplayedGoalOption(image: "dumbbell", title: "체력을 키울래요", subtitle: "30분 달리기", isSelected: isSelected)
        case .zone2:
            return DisplayedGoalOption(image: "heart", title: "지구력을 키울래요", subtitle: "Zone2 러닝", isSelected: isSelected)
        }
    }
}

extension GoalOptionSelectPresenter: GoalOptionSelectPresentationLogic {
    func presentGoalOptions(response: GoalOptionSelect.LoadGoalOptions.Response) {
        let displayed = response.goalOptions.enumerated().map { index, goal in
            makeDisplayedGoalOption(from: goal, isSelected: index == response.selectedIndex)
        }
        
        viewController?.displayGoalOptions(
            viewModel: .init(displayedGoalOptions: displayed)
        )
    }

    func presentSelectedGoalOption(response: GoalOptionSelect.SelectGoalOption.Response) {
        let displayed = response.goalOptions.enumerated().map { index, goal in
            makeDisplayedGoalOption(from: goal, isSelected: index == response.selectedIndex)
        }
        
        viewController?.displaySelectedGoalOption(
            viewModel: .init(
                displayedGoalOptions: displayed,
                selectedIndex: response.selectedIndex,
                previousIndex: response.previousIndex
            )
        )
    }
}
