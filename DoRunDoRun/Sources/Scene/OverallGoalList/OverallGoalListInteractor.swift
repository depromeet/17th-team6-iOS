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
    func selectSessionGoal(request: OverallGoalList.SelectSessionGoal.Request)
}

protocol OverallGoalListDataStore {
    var overallGoal: OverallGoal? { get set }
    var sessionGoals: [SessionGoal] { get set }
    var selectedIndex: Int? { get set }
}

final class OverallGoalListInteractor: OverallGoalListDataStore {
    var presenter: OverallGoalListPresentationLogic?
    var worker: OverallGoalListWorker = OverallGoalListWorker()

    var overallGoal: OverallGoal?
    var sessionGoals: [SessionGoal] = []
    var selectedIndex: Int?
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
                self.sessionGoals = sessionGoals
                let response = OverallGoalList.LoadSessionGoals.Response(sessionGoals: sessionGoals)
                presenter?.presentSessionGoals(response: response, overallGoal: overallGoal)
            } catch {
                print("🚨 Error: \(error.localizedDescription)")
            }
        }
    }
    
    func selectSessionGoal(request: OverallGoalList.SelectSessionGoal.Request) {
        let selectedGoal = sessionGoals[request.index]

        guard selectedGoal.roundCount <= overallGoal?.currentRoundCount ?? 0 else {
            presenter?.presentSelectedSessionGoal(
                response: .init(
                    sessionGoals: sessionGoals,
                    selectedIndex: selectedIndex,
                    previousIndex: selectedIndex,
                    errorMessage: "이전 회차를 끝내야 도전할 수 있어요."
                ), overallGoal: overallGoal
            )
            return
        }

        let previousIndex = selectedIndex
        if selectedIndex == request.index {
            selectedIndex = nil
        } else {
            selectedIndex = request.index
        }

        presenter?.presentSelectedSessionGoal(
            response: .init(
                sessionGoals: sessionGoals,
                selectedIndex: selectedIndex,
                previousIndex: previousIndex,
                errorMessage: nil
            ), overallGoal: overallGoal
        )
    }

}
