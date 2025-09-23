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
}

extension GoalOptionSelectPresenter: GoalOptionSelectPresentationLogic {
    func presentGoalOptions(response: GoalOptionSelect.LoadGoalOptions.Response) {
        let displayed = response.goalOptions.enumerated().map { index, goal in
            DisplayedGoalOption(
                image: goal.image,
                title: goal.title,
                subtitle: goal.subtitle,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displayGoalOptions(
            viewModel: .init(displayedGoalOptions: displayed)
        )
    }

    func presentSelectedGoalOption(response: GoalOptionSelect.SelectGoalOption.Response) {
        let displayed = response.goalOptions.enumerated().map { index, goal in
            DisplayedGoalOption(
                image: goal.image,
                title: goal.title,
                subtitle: goal.subtitle,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displaySelectedGoalOption(
            viewModel: .init(displayedGoalOptions: displayed, selectedIndex: response.selectedIndex, previousIndex: response.previousIndex)
        )
    }
}
