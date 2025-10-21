//
//  UIApplication+TabBar.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import UIKit

extension UIApplication {

    /// 탭바를 숨기거나 다시 표시합니다.
    func setTabBarHidden(_ hidden: Bool) {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let root = window.rootViewController else { return }

        func findTabBarController(in vc: UIViewController) -> UITabBarController? {
            if let tab = vc as? UITabBarController {
                return tab
            }
            for child in vc.children {
                if let found = findTabBarController(in: child) {
                    return found
                }
            }
            return nil
        }

        if let tabBarController = findTabBarController(in: root) {
            tabBarController.tabBar.isHidden = hidden
        }
    }
}
