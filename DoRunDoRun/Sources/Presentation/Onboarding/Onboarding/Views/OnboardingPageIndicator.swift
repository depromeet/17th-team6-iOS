//
//  OnboardingPageIndicator.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI

struct OnboardingPageIndicator: View {
    let currentPage: Int
    let totalCount: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.blue600 : Color.gray300)
                    .frame(width: index == currentPage ? 16 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingPageIndicator(currentPage: 0, totalCount: 3)
}
