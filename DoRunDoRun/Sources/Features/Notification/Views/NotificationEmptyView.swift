//
//  NotificationEmptyView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/31/25.
//

import SwiftUI

struct EmptyNotificationView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(.empty2)
                .frame(width: 120, height: 120)
            TypographyText(text: "아직 알림이 없어요..", style: .t2_700)
        }
    }
}

// MARK: - Preview
#Preview {
    EmptyNotificationView()
}
