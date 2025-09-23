//
//  OnboardingGuidePresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGuidePresentationLogic {
    func presentRecommendedGoals(response: OnboardingGuide.LoadRecommendedGoals.Response)
    func presentSelectedRecommendedGoal(response: OnboardingGuide.SelectRecommendedGoal.Response)
}

final class OnboardingGuidePresenter {
    weak var viewController: OnboardingGuideDisplayLogic?
}

extension OnboardingGuidePresenter: OnboardingGuidePresentationLogic {
    func presentRecommendedGoals(response: OnboardingGuide.LoadRecommendedGoals.Response) {
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
    
    func presentSelectedRecommendedGoal(response: OnboardingGuide.SelectRecommendedGoal.Response) {
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
