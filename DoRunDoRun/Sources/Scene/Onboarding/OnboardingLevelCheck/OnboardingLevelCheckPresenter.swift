//
//  OnboardingLevelCheckPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckPresentationLogic {
    func presentLevels(response: OnboardingLevelCheck.LoadLevels.Response)
    func presentSelectedLevel(response: OnboardingLevelCheck.SelectLevel.Response)
}

final class OnboardingLevelCheckPresenter {
    weak var viewController: OnboardingLevelCheckDisplayLogic?
}

extension OnboardingLevelCheckPresenter: OnboardingLevelCheckPresentationLogic {
    func presentLevels(response: OnboardingLevelCheck.LoadLevels.Response) {
        let displayed = response.levels.enumerated().map { index, level in
            DisplayedLevel(
                image: level.image,
                title: level.title,
                subtitle: level.subtitle,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displayLevels(
            viewModel: .init(displayedLevels: displayed)
        )
    }
    
    func presentSelectedLevel(response: OnboardingLevelCheck.SelectLevel.Response) {
        let displayed = response.levels.enumerated().map { index, level in
            DisplayedLevel(
                image: level.image,
                title: level.title,
                subtitle: level.subtitle,
                isSelected: index == response.selectedIndex
            )
        }
        viewController?.displaySelectedLevel(
            viewModel: .init(
                displayedLevels: displayed,
                selectedIndex: response.selectedIndex,
                previousIndex: response.previousIndex
            )
        )
    }
}
