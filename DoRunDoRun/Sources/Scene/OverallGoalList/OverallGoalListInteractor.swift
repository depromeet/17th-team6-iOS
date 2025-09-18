//
//  OverallGoalListInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListBusinessLogic {
}

protocol OverallGoalListDataStore {
    //var name: String { get set }
}

final class OverallGoalListInteractor: OverallGoalListDataStore {
    var presenter: OverallGoalListPresentationLogic?
    //var name: String = ""
    
    // MARK: Do something
    
}

extension OverallGoalListInteractor: OverallGoalListBusinessLogic {
    
}
