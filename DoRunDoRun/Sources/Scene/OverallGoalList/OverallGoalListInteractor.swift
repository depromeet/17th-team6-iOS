//
//  OverallGoalListInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListBusinessLogic {
    func getOverallGoal(request: OverallGoalList.GetOverallGoal.Request)
    func loadSessionGoals(request: OverallGoalList.LoadSessionGoals.Request)
}

protocol OverallGoalListDataStore {
    var overallGoal: OverallGoal? { get set }
    var sessionGoals: [SessionGoal] { get set }
}

final class OverallGoalListInteractor: OverallGoalListDataStore {
    var presenter: OverallGoalListPresentationLogic?
    var worker: OverallGoalListWorker = OverallGoalListWorker()

    var overallGoal: OverallGoal?
    var sessionGoals: [SessionGoal] = []
}

extension OverallGoalListInteractor: OverallGoalListBusinessLogic {
    func getOverallGoal(request: OverallGoalList.GetOverallGoal.Request) {
        guard let overallGoal else { return }
        presenter?.presentOverallGoal(response: .init(overallGoal: overallGoal))
    }
    
    func loadSessionGoals(request: OverallGoalList.LoadSessionGoals.Request) {
        Task {
            do {
                let sessionGoals = try await worker.loadSessionGoals()
                let response = OverallGoalList.LoadSessionGoals.Response(sessionGoals: sessionGoals)
                presenter?.presentSessionGoals(response: response, overallGoal: overallGoal)
            } catch {
                print("🚨 Error: \(error.localizedDescription)")
            }
        }
    }
}
