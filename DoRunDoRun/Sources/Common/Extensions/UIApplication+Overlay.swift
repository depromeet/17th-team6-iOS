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
    static func presentOverlay<Content: View>(
        @ViewBuilder content: () -> Content
    ) {
        guard let window = keyWindow else { return }

        // HostingController 생성
        let hosting = UIHostingController(rootView: content().ignoresSafeArea())
        hosting.view.backgroundColor = .clear
        hosting.view.frame = window.bounds
        hosting.view.tag = 9999 // 중복 방지 태그

        // 기존 오버레이 제거 후 새로 추가
        dismissOverlay()
        window.addSubview(hosting.view)
    }

    /// 기존 오버레이 제거
    static func dismissOverlay() {
        keyWindow?.viewWithTag(9999)?.removeFromSuperview()
    }
}
