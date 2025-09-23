//
//  OnboardingLevelCheckPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckPresentationLogic {
    func presentRunningLevels(response: OnboardingLevelCheck.LoadRunningLevels.Response)
    func presentSelectedRunningLevel(response: OnboardingLevelCheck.SelectRunningLevel.Response)
}

final class OnboardingLevelCheckPresenter {
    weak var viewController: OnboardingLevelCheckDisplayLogic?
}

extension OnboardingLevelCheckPresenter: OnboardingLevelCheckPresentationLogic {
    func presentRunningLevels(response: OnboardingLevelCheck.LoadRunningLevels.Response) {
        let displayed = response.runningLevels.enumerated().map { index, level in
            DisplayedRunningLevel(
                image: level.image,
                title: level.title,
                subtitle: level.subtitle,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displayRunningLevels(
            viewModel: .init(displayedRunningLevels: displayed)
        )
    }
    
    func presentSelectedRunningLevel(response: OnboardingLevelCheck.SelectRunningLevel.Response) {
        let displayed = response.runningLevels.enumerated().map { index, level in
            DisplayedRunningLevel(
                image: level.image,
                title: level.title,
                subtitle: level.subtitle,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displaySelectedRunningLevel(
            viewModel: .init(displayedLevels: displayed, selectedIndex: response.selectedIndex, previousIndex: response.previousIndex)
        )
    }
}
