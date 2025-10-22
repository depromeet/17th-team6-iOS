//
//  OnboardingPageView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI

/// 온보딩의 각 페이지에 사용되는 단일 View
struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            // 상단 이미지
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 268, maxHeight: 268)
                .background(Color.gray100)

            // 텍스트 영역
            VStack(spacing: 12) {
                TypographyText(text: title, style: .h2_700, color: .gray900)
                TypographyText(text: subtitle, style: .b1_400, color: .gray700)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingPageView(
        imageName: "onboarding_1",
        title: "혼자 뛰는 건 어려워도,\n함께라면 두런두런 즐겁게!",
        subtitle: "친구와 함께 러닝을 습관으로 만들어보세요."
    )
}
