//
//  OnboardingLevelCheckInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingLevelCheckBusinessLogic {
    func loadLevels(request: OnboardingLevelCheck.LoadLevels.Request)
    func selectLevel(request: OnboardingLevelCheck.SelectLevel.Request)
}

protocol OnboardingLevelCheckDataStore {
    var levels: [RunningLevel] { get set }
    var selectedIndex: Int { get set }
}

final class OnboardingLevelCheckInteractor: OnboardingLevelCheckDataStore {
    var presenter: OnboardingLevelCheckPresentationLogic?
    var levels: [RunningLevel] = [
        RunningLevel(image: "shoe", title: "이제 막 시작했어요", subtitle: "최근 달린 경험이 없어요."),
        RunningLevel(image: "shoe", title: "가끔 달려요", subtitle: "주 1-2회 이하로 가볍게 달려요."),
        RunningLevel(image: "shoe", title: "꾸준히 달려요", subtitle: "주 3회 이상 루틴대로 달려요.")
    ]
    var selectedIndex: Int = 0
}

extension OnboardingLevelCheckInteractor: OnboardingLevelCheckBusinessLogic {
    func loadLevels(request: OnboardingLevelCheck.LoadLevels.Request) {
        presenter?.presentLevels(
            response: .init(levels: levels, selectedIndex: selectedIndex)
        )
    }
    
    func selectLevel(request: OnboardingLevelCheck.SelectLevel.Request) {
        let previousIndex = selectedIndex
        selectedIndex = request.index
        presenter?.presentSelectedLevel(
            response: .init(levels: levels, selectedIndex: selectedIndex, previousIndex: previousIndex)
        )
    }
}
