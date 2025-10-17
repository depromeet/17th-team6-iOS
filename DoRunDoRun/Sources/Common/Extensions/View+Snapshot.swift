//
//  View+Snapshot.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/16/25.
//

import SwiftUI

extension View {
    /// 현재 View를 UIImage로 캡처하는 헬퍼 메서드
    ///
    /// ```
    /// let image = someView.snapshot()
    /// ```
    /// - Returns: View 전체를 렌더링한 UIImage
    ///
    /// 이 메서드는 Safe Area를 제거한 상태로 실제 View의 사이즈를 계산하고,
    /// AutoLayout을 한 번 갱신한 뒤 `UIGraphicsImageRenderer`를 통해 이미지를 생성합니다.
    func snapshot() -> UIImage {
        // Safe Area 제거
        let controller = UIHostingController(rootView: self.ignoresSafeArea())
        let view = controller.view

        // AutoLayout 사이클을 한 번 돌려서 실제 사이즈를 계산
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        // 이미지 렌더링
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
