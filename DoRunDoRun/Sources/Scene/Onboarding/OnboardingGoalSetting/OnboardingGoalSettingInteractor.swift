//
//  OnboardingGoalSettingInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingGoalSettingBusinessLogic {
    func loadGoalOptions(request: OnboardingGoalSetting.LoadGoalOptions.Request)
    func selectGoalOption(request: OnboardingGoalSetting.SelectGoalOption.Request)
}

protocol OnboardingGoalSettingDataStore {
    var goalOptions: [GoalOption] { get set }
    var selectedIndex: Int { get set }
}

final class OnboardingGoalSettingInteractor: OnboardingGoalSettingDataStore {
    var presenter: OnboardingGoalSettingPresentationLogic?
    var goalOptions: [GoalOption] = [
        GoalOption(image: "flag", title: "마라톤에 도전할래요", subtitle: "10km · 21km · 42km"),
        GoalOption(image: "dumbbell", title: "체력을 키울래요", subtitle: "30분 달리기"),
        GoalOption(image: "heart", title: "지구력을 키울래요", subtitle: "Zone2 러닝")
    ]
    var selectedIndex: Int = 0
}

extension OnboardingGoalSettingInteractor: OnboardingGoalSettingBusinessLogic {
    func loadGoalOptions(request: OnboardingGoalSetting.LoadGoalOptions.Request) {
        presenter?.presentGoalOptions(
            response: .init(goalOptions: goalOptions, selectedIndex: selectedIndex)
        )
    }

    func selectGoalOption(request: OnboardingGoalSetting.SelectGoalOption.Request) {
        let previousIndex = selectedIndex
        selectedIndex = request.index
        presenter?.presentSelectedGoalOption(
            response: .init(goalOptions: goalOptions,
                            selectedIndex: selectedIndex,
                            previousIndex: previousIndex)
        )
    }
}
