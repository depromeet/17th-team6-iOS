//
//  OverallGoalListPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListPresentationLogic {
    func presentSessionGoals(response: OverallGoalList.LoadSessionGoals.Response)
}

final class OverallGoalListPresenter {
    weak var viewController: OverallGoalListDisplayLogic?
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "00:00:00"
    }
}

extension OverallGoalListPresenter: OverallGoalListPresentationLogic {
    func presentSessionGoals(response: OverallGoalList.LoadSessionGoals.Response) {
        let displayedSessionGoals = response.sessionGoals.map {
            OverallGoalList.LoadSessionGoals.ViewModel.DisplayedSessionGoal(
                round: "\($0.round)회차",
                distance: String(format: "%.1f km", $0.distance),
                time: formatTime($0.time),
                pace: $0.pace,
                isCompleted: $0.isCompleted
            )
        }
        
        let viewModel = OverallGoalList.LoadSessionGoals.ViewModel(displayedSessionGoals: displayedSessionGoals)
        viewController?.displaySessionGoals(viewModel: viewModel)
    }
}
