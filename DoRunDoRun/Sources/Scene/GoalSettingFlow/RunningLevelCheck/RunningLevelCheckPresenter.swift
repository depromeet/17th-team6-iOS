//
//  RunningLevelCheckPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RunningLevelCheckPresentationLogic {
    func presentRunningLevels(response: RunningLevelCheck.LoadRunningLevels.Response)
    func presentSelectedRunningLevel(response: RunningLevelCheck.SelectRunningLevel.Response)
}

final class RunningLevelCheckPresenter {
    weak var viewController: RunningLevelCheckDisplayLogic?
}

extension RunningLevelCheckPresenter: RunningLevelCheckPresentationLogic {
    func presentRunningLevels(response: RunningLevelCheck.LoadRunningLevels.Response) {
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
    
    func presentSelectedRunningLevel(response: RunningLevelCheck.SelectRunningLevel.Response) {
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
