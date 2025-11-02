//
//  OnboardingPageView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let image: Image
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 268, maxHeight: 268)
            
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
        image: Image(.onboarding1),
        title: "혼자 뛰는 건 어려워도,\n함께라면 두런두런 즐겁게!",
        subtitle: "친구와 함께 러닝을 습관으로 만들어보세요."
    )
}
