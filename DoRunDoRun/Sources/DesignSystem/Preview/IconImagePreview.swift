//
//  IconImagePreview.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import SwiftUI

struct IconImagePreview: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(.icCheckS)
                Image(.icCheckM)
                Image(.icCheckCircleM)
                Image(.icCheckCircleFillM)
            }
            Divider()
            HStack(spacing: 8) {
                Image(.check, size: .small)
                Image(.check, size: .medium)
                Image(.checkCircle, fill: .normal)
                Image(.checkCircle, fill: .fill)
            }
        }
        .padding()
    }
}

#Preview {
    IconImagePreview()
}
