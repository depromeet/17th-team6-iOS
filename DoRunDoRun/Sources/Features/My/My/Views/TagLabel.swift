//
//  TagLabel.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import SwiftUI

/// 인증 상태를 표시하는 태그 라벨 뷰
struct TagLabel: View {
    let status: CertificationStatus

    private var text: String {
        switch status {
        case .completed: "인증 완료"
        case .possible: "인증 가능"
        case .none: ""
        }
    }

    private var textColor: Color {
        switch status {
        case .possible: .blue600
        case .completed: .gray0
        case .none: .clear
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .completed: .blue600
        case .possible: .blue100
        case .none: .clear
        }
    }

    var body: some View {
        if status != .none {
            TypographyText(text: text, style: .c1_500, color: textColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background(backgroundColor)
                .cornerRadius(13)
        }
    }
}
