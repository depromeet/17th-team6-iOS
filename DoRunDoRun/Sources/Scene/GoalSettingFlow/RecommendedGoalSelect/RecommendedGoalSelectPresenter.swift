//
//  RecommendedGoalSelectPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RecommendedGoalSelectPresentationLogic {
    func presentRecommendedGoals(response: RecommendedGoalSelect.LoadRecommendedGoals.Response)
    func presentSelectedRecommendedGoal(response: RecommendedGoalSelect.SelectRecommendedGoal.Response)
}

final class RecommendedGoalSelectPresenter {
    weak var viewController: RecommendedGoalSelectDisplayLogic?
}

extension RecommendedGoalSelectPresenter: RecommendedGoalSelectPresentationLogic {
    func presentRecommendedGoals(response: RecommendedGoalSelect.LoadRecommendedGoals.Response) {
        let displayedGoals = response.recommendedGoals.enumerated().map { index, goal in
            DisplayedRecommendedGoal(
                icon: goal.icon,
                title: goal.title,
                subTitle: goal.subTitle,
                count: goal.count,
                time: goal.time,
                pace: goal.pace,
                isRecommended: goal.isRecommended,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displayRecommendedGoals(viewModel: .init(displayedRecommendedGoals: displayedGoals))
    }
    
    func presentSelectedRecommendedGoal(response: RecommendedGoalSelect.SelectRecommendedGoal.Response) {
        let displayedGoals = response.goals.enumerated().map { index, goal in
            DisplayedRecommendedGoal(
                icon: goal.icon,
                title: goal.title,
                subTitle: goal.subTitle,
                count: goal.count,
                time: goal.time,
                pace: goal.pace,
                isRecommended: goal.isRecommended,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displaySelectedRecommendedGoal(
            viewModel: .init(
                displayedGoals: displayedGoals,
                selectedIndex: response.selectedIndex,
                previousIndex: response.previousIndex
            )
        )
    }
}
