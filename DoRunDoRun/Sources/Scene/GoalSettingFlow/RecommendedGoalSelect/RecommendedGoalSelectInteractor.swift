//
//  RecommendedGoalSelectInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RecommendedGoalSelectBusinessLogic {
    func loadRecommendedGoals(request: RecommendedGoalSelect.LoadRecommendedGoals.Request)
    func selectRecommendedGoal(request: RecommendedGoalSelect.SelectRecommendedGoal.Request)
    func startWithGoal(request: RecommendedGoalSelect.Start.Request)
}

protocol RecommendedGoalSelectDataStore {
    var selectedGoalOption: GoalOption? { get set }
    var recommendedGoals: [RecommendedGoal] { get set }
    var selectedIndex: Int { get set }
}

final class RecommendedGoalSelectInteractor: RecommendedGoalSelectDataStore {
    var presenter: RecommendedGoalSelectPresentationLogic?
    var worker: RecommendedGoalSelectWorker = RecommendedGoalSelectWorker()

    var selectedGoalOption: GoalOption?
    var recommendedGoals: [RecommendedGoal] = []
    var selectedIndex: Int = 0
}

extension RecommendedGoalSelectInteractor: RecommendedGoalSelectBusinessLogic {
    func loadRecommendedGoals(request: RecommendedGoalSelect.LoadRecommendedGoals.Request) {
        guard let selectedGoalOption else { return }
        
        Task {
            do {
                let recommendedGoals = try await worker.loadRecommendedGoals(goalOption: selectedGoalOption)
                self.recommendedGoals = recommendedGoals
                presenter?.presentRecommendedGoals(
                    response: .init(recommendedGoals: recommendedGoals, selectedIndex: selectedIndex)
                )
            } catch {
                print("🚨 Error: \(error.localizedDescription)")
            }
        }
    }
    
    func selectRecommendedGoal(request: RecommendedGoalSelect.SelectRecommendedGoal.Request) {
        let previousIndex = selectedIndex
        selectedIndex = request.index
        presenter?.presentSelectedRecommendedGoal(
            response: .init(goals: recommendedGoals, selectedIndex: selectedIndex, previousIndex: previousIndex)
        )
    }
    
    func startWithGoal(request: RecommendedGoalSelect.Start.Request) {
        Task {
            do {
                let goal = recommendedGoals[selectedIndex]
                
                let entity = OverallGoal(
                    id: 0,
                    createdAt: .now,
                    updatedAt: nil,
                    pausedAt: nil,
                    clearedAt: nil,
                    title: goal.title,
                    subTitle: goal.subTitle,
                    type: goal.type,
                    pace: goal.pace,
                    distance: goal.distance,
                    duration: goal.duration,
                    currentRoundCount: 1,
                    totalRoundCount: goal.totalRoundCount
                )
                let overallGoal = try await worker.addOverallGoal(entity: entity)
                presenter?.presentStart(response: .init(overallGoal: overallGoal))
            } catch {
                print("🚨 Error: \(error.localizedDescription)")
            }
        }
    }
}
