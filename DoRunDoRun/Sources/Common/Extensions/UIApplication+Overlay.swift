//
//  UIApplication+Overlay.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI

extension UIApplication {
    /// 현재 활성화된 UIWindow를 반환
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: \.isKeyWindow) }
            .first
    }

    /// SwiftUI 뷰를 UIKit 윈도우 최상단에 표시
    static func presentOverlay<Dim: View, Sheet: View>(
         @ViewBuilder dim: @escaping () -> Dim,
         @ViewBuilder sheet: @escaping () -> Sheet
     ) {
         guard let window = keyWindow else { return }

         dismissOverlay()

         let container = UIView(frame: window.bounds)
         container.backgroundColor = .clear
         container.tag = 9999

         // ✔ dim만 담는 hosting
         let dimHosting = UIHostingController(rootView: dim().ignoresSafeArea())
         dimHosting.view.backgroundColor = .clear
         dimHosting.view.frame = container.bounds
         dimHosting.view.alpha = 0 // fade

         // ✔ sheet만 담는 hosting
         let sheetHosting = UIHostingController(rootView: sheet().ignoresSafeArea())
         sheetHosting.view.backgroundColor = .clear
         sheetHosting.view.frame = container.bounds
         sheetHosting.view.transform = CGAffineTransform(translationX: 0, y: 200) // 아래에서 시작

         container.addSubview(dimHosting.view)
         container.addSubview(sheetHosting.view)

         window.addSubview(container)

         UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
             dimHosting.view.alpha = 1
             sheetHosting.view.transform = .identity
         }
     }

    /// 기존 오버레이 제거
    static func dismissOverlay() {
        keyWindow?.viewWithTag(9999)?.removeFromSuperview()
    }
}
