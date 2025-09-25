//
//  RunningLevelCheckInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol RunningLevelCheckBusinessLogic {
    func loadRunningLevels(request: RunningLevelCheck.LoadRunningLevels.Request)
    func selectRunningLevel(request: RunningLevelCheck.SelectRunningLevel.Request)
}

protocol RunningLevelCheckDataStore {
    var runningLevels: [RunningLevel] { get set }
    var selectedIndex: Int { get set }
}

final class RunningLevelCheckInteractor: RunningLevelCheckDataStore {
    var presenter: RunningLevelCheckPresentationLogic?
    var runningLevels: [RunningLevel] = [
        RunningLevel(image: "shoe", title: "이제 막 시작했어요", subtitle: "최근 달린 경험이 없어요."),
        RunningLevel(image: "shoe", title: "가끔 달려요", subtitle: "주 1-2회 이하로 가볍게 달려요."),
        RunningLevel(image: "shoe", title: "꾸준히 달려요", subtitle: "주 3회 이상 루틴대로 달려요.")
    ]
    var selectedIndex: Int = 0
}

extension RunningLevelCheckInteractor: RunningLevelCheckBusinessLogic {
    func loadRunningLevels(request: RunningLevelCheck.LoadRunningLevels.Request) {
        presenter?.presentRunningLevels(
            response: .init(runningLevels: runningLevels, selectedIndex: selectedIndex)
        )
    }
    
    func selectRunningLevel(request: RunningLevelCheck.SelectRunningLevel.Request) {
        let previousIndex = selectedIndex
        selectedIndex = request.index
        presenter?.presentSelectedRunningLevel(
            response: .init(runningLevels: runningLevels, selectedIndex: selectedIndex, previousIndex: previousIndex)
        )
    }
}
