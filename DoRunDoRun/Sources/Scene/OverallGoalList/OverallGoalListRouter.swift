//
//  OverallGoalListRouter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/18/25.
//

import UIKit

protocol OverallGoalListRoutingLogic {
}

protocol OverallGoalListDataPassing {
    var dataStore: OverallGoalListDataStore? { get }
}

final class OverallGoalListRouter: OverallGoalListRoutingLogic, OverallGoalListDataPassing {
    weak var viewController: OverallGoalListViewController?
    var dataStore: OverallGoalListDataStore?
    
    // MARK: Routing
    
    //func routeToSomewhere(segue: UIStoryboardSegue?)
    //{
    //  if let segue = segue {
    //    let destinationVC = segue.destination as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //  } else {
    //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    navigateToSomewhere(source: viewController!, destination: destinationVC)
    //  }
    //}
    
    // MARK: Navigation
    
    //func navigateToSomewhere(source: ProfileViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}
    
    // MARK: Passing data
    
    //func passDataToSomewhere(source: ProfileDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}
