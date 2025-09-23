//
//  OnboardingLevelCheckInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckBusinessLogic {
    func loadRunningLevels(request: OnboardingLevelCheck.LoadRunningLevels.Request)
    func selectRunningLevel(request: OnboardingLevelCheck.SelectRunningLevel.Request)
}

protocol OnboardingLevelCheckDataStore {
    var runningLevels: [RunningLevel] { get set }
    var selectedIndex: Int { get set }
}

final class OnboardingLevelCheckInteractor: OnboardingLevelCheckDataStore {
    var presenter: OnboardingLevelCheckPresentationLogic?
    var runningLevels: [RunningLevel] = [
        RunningLevel(image: "shoe", title: "이제 막 시작했어요", subtitle: "최근 달린 경험이 없어요."),
        RunningLevel(image: "shoe", title: "가끔 달려요", subtitle: "주 1-2회 이하로 가볍게 달려요."),
        RunningLevel(image: "shoe", title: "꾸준히 달려요", subtitle: "주 3회 이상 루틴대로 달려요.")
    ]
    var selectedIndex: Int = 0
}

extension OnboardingLevelCheckInteractor: OnboardingLevelCheckBusinessLogic {
    func loadRunningLevels(request: OnboardingLevelCheck.LoadRunningLevels.Request) {
        presenter?.presentRunningLevels(
            response: .init(runningLevels: runningLevels, selectedIndex: selectedIndex)
        )
    }
    
    func selectRunningLevel(request: OnboardingLevelCheck.SelectRunningLevel.Request) {
        let previousIndex = selectedIndex
        selectedIndex = request.index
        presenter?.presentSelectedRunningLevel(
            response: .init(runningLevels: runningLevels, selectedIndex: selectedIndex, previousIndex: previousIndex)
        )
    }
}
