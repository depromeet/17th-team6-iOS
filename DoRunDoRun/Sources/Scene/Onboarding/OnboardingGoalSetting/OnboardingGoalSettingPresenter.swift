//
//  OnboardingGoalSettingPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGoalSettingPresentationLogic {
    func presentGoalOptions(response: OnboardingGoalSetting.LoadGoalOptions.Response)
    func presentSelectedGoalOption(response: OnboardingGoalSetting.SelectGoalOption.Response)
}

final class OnboardingGoalSettingPresenter {
    weak var viewController: OnboardingGoalSettingDisplayLogic?
}

extension OnboardingGoalSettingPresenter: OnboardingGoalSettingPresentationLogic {
    func presentGoalOptions(response: OnboardingGoalSetting.LoadGoalOptions.Response) {
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

    func presentSelectedGoalOption(response: OnboardingGoalSetting.SelectGoalOption.Response) {
        let displayed = response.goalOptions.enumerated().map { index, goal in
            DisplayedGoalOption(
                image: goal.image,
                title: goal.title,
                subtitle: goal.subtitle,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displaySelectedGoalOption(
            viewModel: .init(displayedGoalOptions: displayed,
                             selectedIndex: response.selectedIndex,
                             previousIndex: response.previousIndex)
        )
    }
}
