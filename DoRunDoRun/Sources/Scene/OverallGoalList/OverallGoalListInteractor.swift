//
//  OverallGoalListInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListBusinessLogic {
    func loadSessionGoals(request: OverallGoalList.LoadSessionGoals.Request)
}

protocol OverallGoalListDataStore {
    var sessionGoals: [SessionGoal] { get set }

}

final class OverallGoalListInteractor: OverallGoalListDataStore {
    var presenter: OverallGoalListPresentationLogic?
    var sessionGoals: [SessionGoal] = []
}

extension OverallGoalListInteractor: OverallGoalListBusinessLogic {
    func loadSessionGoals(request: OverallGoalList.LoadSessionGoals.Request) {
        // 서버 없으니 Mock 데이터 생성
        sessionGoals = (1...10).map { index in
            SessionGoal(
                round: index,
                subtitle: "",
                distance: 1,
                time: 3600,
                pace: "6'74''",
                isCompleted: index <= 3
            )
        }
        
        let response = OverallGoalList.LoadSessionGoals.Response(sessionGoals: sessionGoals)
        presenter?.presentSessionGoals(response: response)
    }
}
