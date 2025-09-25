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
    
    private func mapIcon(for type: String) -> String {
        switch type {
        case "MARATHON": return "flag"
        case "STAMINA": return "dumbbell"
        case "ZONE_2": return "heart"
        default: return "circle"
        }
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return String(format: "%02d:%02d:00", hours, mins)
        } else {
            return String(format: "00:%02d:00", mins)
        }
    }
    
    private func formatPace(_ secondsPerKm: Int) -> String {
        let minutes = secondsPerKm / 60
        let seconds = secondsPerKm % 60
        return "\(minutes)'\(String(format: "%02d", seconds))\""
    }
}

extension RecommendedGoalSelectPresenter: RecommendedGoalSelectPresentationLogic {
    func presentRecommendedGoals(response: RecommendedGoalSelect.LoadRecommendedGoals.Response) {
        let displayedGoals = response.recommendedGoals.enumerated().map { index, goal in
            DisplayedRecommendedGoal(
                icon: mapIcon(for: goal.type),
                title: goal.title,
                subTitle: goal.subTitle,
                count: "\(goal.totalRoundCount)회",
                time: formatDuration(goal.duration),
                pace: formatPace(goal.pace),
                isRecommended: goal.isRecommended,
                isSelected: index == response.selectedIndex
            )
        }
        
        Task { @MainActor in
            viewController?.displayRecommendedGoals(
                viewModel: .init(displayedRecommendedGoals: displayedGoals)
            )
        }
    }
    
    func presentSelectedRecommendedGoal(response: RecommendedGoalSelect.SelectRecommendedGoal.Response) {
        let displayedGoals = response.goals.enumerated().map { index, goal in
            DisplayedRecommendedGoal(
                icon: mapIcon(for: goal.type),
                title: goal.title,
                subTitle: goal.subTitle,
                count: "\(goal.totalRoundCount)회",
                time: formatDuration(goal.duration),
                pace: formatPace(goal.pace),
                isRecommended: goal.isRecommended,
                isSelected: index == response.selectedIndex
            )
        }
        
        Task { @MainActor in
            viewController?.displaySelectedRecommendedGoal(
                viewModel: .init(displayedGoals: displayedGoals, selectedIndex: response.selectedIndex, previousIndex: response.previousIndex
                )
            )
        }
    }
}
