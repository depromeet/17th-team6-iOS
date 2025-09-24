//
//  MainTabViewController.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/13/25.
//

import UIKit

final class MainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let viewControllers = createViewControllers()
        setViewControllers(viewControllers, animated: false)
        
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
    
    private func createViewControllers() -> [UIViewController] {
        let homeVC = createNavigationController(
            rootViewController: HomeViewController(),
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let runningVC = createNavigationController(
            rootViewController: RunningViewController(),
            title: "런닝",
            image: UIImage(systemName: "figure.run"),
            selectedImage: UIImage(systemName: "figure.run.circle.fill")
        )
        
        let recordVC = createNavigationController(
            rootViewController: RecordViewController(),
            title: "기록",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        let profileVC = createNavigationController(
            rootViewController: ProfileViewController(),
            title: "프로필",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        return [homeVC, runningVC, recordVC, profileVC]
    }
    
    private func createNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: UIImage?,
        selectedImage: UIImage?
    ) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
        return navigationController
    }
}
