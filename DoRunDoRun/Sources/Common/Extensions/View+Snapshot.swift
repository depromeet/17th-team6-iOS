//
//  View+Snapshot.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import SwiftUI

extension View {
    /// 현재 View를 UIImage로 캡처하는 헬퍼 메서드
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

