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
}

protocol RecommendedGoalSelectDataStore {
    var selectedGoalOption: GoalOption? { get set }
    var recommendedGoals: [RecommendedGoal] { get set }
    var selectedIndex: Int { get set }
}

final class RecommendedGoalSelectInteractor: RecommendedGoalSelectDataStore {
    var presenter: RecommendedGoalSelectPresentationLogic?
    var selectedGoalOption: GoalOption?
    var recommendedGoals: [RecommendedGoal] = [
        RecommendedGoal(icon: "flag", title: "10km 마라톤 완주", subTitle: "초보 러너도 안정적으로 완주할 수 있어요!", count: "32", time: "01:00:00", pace: "6'30''", isRecommended: true),
        RecommendedGoal(icon: "flag", title: "21km 마라톤 완주", subTitle: "한계를 넘어서는 도전, 함께 성장해봐요!", count: "32", time: "02:20:00", pace: "7'00''", isRecommended: false),
        RecommendedGoal(icon: "flag", title: "42km 마라톤 완주", subTitle: "러너라면 한 번쯤 꿈꾸는 목표에 도전해보세요!", count: "32", time: "4:40:00", pace: "7'00''", isRecommended: false)
    ]
    var selectedIndex: Int = 0
}

extension RecommendedGoalSelectInteractor: RecommendedGoalSelectBusinessLogic {
    func loadRecommendedGoals(request: RecommendedGoalSelect.LoadRecommendedGoals.Request) {
        // GoalOption에 따라 다른 recommendedGoals 준비
        switch selectedGoalOption?.title {
        case "마라톤에 도전할래요":
            recommendedGoals = [
                RecommendedGoal(icon: "flag", title: "10km 마라톤 완주", subTitle: "초보 러너도 안정적으로 완주할 수 있어요!", count: "32", time: "01:00:00", pace: "6'30''", isRecommended: true),
                RecommendedGoal(icon: "flag", title: "21km 마라톤 완주", subTitle: "한계를 넘어서는 도전, 함께 성장해봐요!", count: "32", time: "02:20:00", pace: "7'00''", isRecommended: false),
                RecommendedGoal(icon: "flag", title: "42km 마라톤 완주", subTitle: "러너라면 한 번쯤 꿈꾸는 목표에 도전해보세요!", count: "32", time: "4:40:00", pace: "7'00''", isRecommended: false)
            ]
        case "체력을 키울래요":
            recommendedGoals = [
                RecommendedGoal(icon: "dumbbell", title: "30분 달리기", subTitle: "러닝의 첫 걸음, 30분 달리기", count: "32", time: "00:30:00", pace: "7'00''", isRecommended: true)
            ]
        case "지구력을 키울래요":
            recommendedGoals = [
                RecommendedGoal(icon: "heart", title: "Zone2 달리기", subTitle: "지방 연소와 지구력 향상", count: "32", time: "02:00:00", pace: "8'00''", isRecommended: true)
            ]
        default: recommendedGoals = []
        }
        
        presenter?.presentRecommendedGoals(
            response: .init(recommendedGoals: recommendedGoals, selectedIndex: selectedIndex)
        )
    }
    
    func selectRecommendedGoal(request: RecommendedGoalSelect.SelectRecommendedGoal.Request) {
        let previousIndex = selectedIndex
        selectedIndex = request.index
        presenter?.presentSelectedRecommendedGoal(
            response: .init(goals: recommendedGoals, selectedIndex: selectedIndex, previousIndex: previousIndex)
        )
    }
}
