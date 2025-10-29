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
                        } else {
                            Image(.checkCircle, fill: .normal, size: .medium)
                                .renderingMode(.template)
                                .foregroundStyle(Color.gray300)
                        }
                        TypographyText(text: store.title, style: .b1_400)
                        Spacer()
                    }
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    store.send(.chevronTapped)
                } label: {
                    Image("ic_chevron_forward")
                }
            }
        }
    }
}
