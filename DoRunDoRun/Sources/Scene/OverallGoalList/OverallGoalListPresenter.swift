//
//  OverallGoalListPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListPresentationLogic {
    func presentOverallGoal(response: OverallGoalList.GetOverallGoal.Response)
    func presentSessionGoals(response: OverallGoalList.LoadSessionGoals.Response, overallGoal: OverallGoal?)
}

final class OverallGoalListPresenter {
    weak var viewController: OverallGoalListDisplayLogic?
    
    private func mapIcon(for type: String) -> String {
        switch type {
        case "MARATHON": return "flag"
        case "STAMINA": return "dumbbell"
        case "ZONE_2": return "heart"
        default: return "circle"
        }
    }

    private func formatDistance(_ meters: Int) -> String {
        let km = Double(meters) / 1000.0
        return String(format: "%.2f km", km)
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

extension OverallGoalListPresenter: OverallGoalListPresentationLogic {
    func presentOverallGoal(response: OverallGoalList.GetOverallGoal.Response) {
        let goal = response.overallGoal

        let progress: Float = Float(goal.currentRoundCount) / Float(goal.totalRoundCount)

        let displayedOverallGoal = OverallGoalList.GetOverallGoal.ViewModel.DisplayedOverallGoal(
            iconName: mapIcon(for: goal.type),
            title: goal.title,
            currentSession: "\(goal.currentRoundCount)회차",
            totalSession: "/ 총 \(goal.totalRoundCount)회",
            progress: progress
        )

        let viewModel = OverallGoalList.GetOverallGoal.ViewModel(displayedOverallGoal: displayedOverallGoal)
        
        Task { @MainActor in
            viewController?.displayOverallGoal(viewModel: viewModel)
        }
    }
    
    func presentSessionGoals(response: OverallGoalList.LoadSessionGoals.Response, overallGoal: OverallGoal?) {
        let displayedSessionGoals = response.sessionGoals.map {
            OverallGoalList.LoadSessionGoals.ViewModel.DisplayedSessionGoal(
                round: "\($0.roundCount)회차",
                distance: formatDistance($0.distance),
                time: formatDuration($0.duration),
                pace: formatPace($0.pace),
                isCompleted: $0.roundCount <= (overallGoal?.currentRoundCount ?? 0)
            )
        }
        
        let viewModel = OverallGoalList.LoadSessionGoals.ViewModel(displayedSessionGoals: displayedSessionGoals)
        
        Task { @MainActor in
            viewController?.displaySessionGoals(viewModel: viewModel)
        }
    }
}
