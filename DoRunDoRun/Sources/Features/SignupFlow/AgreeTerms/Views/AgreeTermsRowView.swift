//
//  AgreeTermsRowView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

import SwiftUI

import ComposableArchitecture

struct AgreeTermsRowView: View {
    let store: StoreOf<AgreeTermsRowFeature>

    var body: some View {
        WithPerceptionTracking {
            HStack {
                Button {
                    store.send(.toggle(!store.isOn))
                } label: {
                    HStack(spacing: 8) {
                        if store.isOn {
                            Image(.checkCircle, fill: .fill, size: .medium)
                                .renderingMode(.template)
                                .foregroundStyle(Color.blue600)
                                .padding(4)
                        } else {
                            Image(.checkCircle, fill: .normal, size: .medium)
                                .renderingMode(.template)
                                .foregroundStyle(Color.gray300)
                                .padding(4)
                        }
                        TypographyText(text: store.title, style: .b1_400, alignment: .left)
                        Spacer()
                    }
                    .clipShape(Rectangle())
                    .background(Color.gray0)
                }
                .buttonStyle(.plain)

                Button {
                    store.send(.chevronTapped)
                } label: {
                    Image(.arrowRight, size: .small)
                }
            }
        }
    }
}
