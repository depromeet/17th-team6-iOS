//
//  NavigationBar.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/23/25.
//

import SwiftUI

struct NavigationBar<RightContent: View>: View {
    private let title: String
    private let rightContent: RightContent

    init(_ title: String, @ViewBuilder rightContent: () -> RightContent = { EmptyView() }) {
        self.title = title
        self.rightContent = rightContent()
    }

    var body: some View {
        HStack {
            Text(title)
                .padding(.leading, 20)
                .font(Font.pretendard(.bold, size: 20))
                .foregroundStyle(Color.gray900)

            Spacer()

            rightContent
                .padding(.trailing, 10)
        }
        .frame(height: 44)
    }
}
