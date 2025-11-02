//
//  AgreeTermsListView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/25/25.
//

import SwiftUI

import ComposableArchitecture

struct AgreeTermsListView: View {
    let store: StoreOf<AgreeTermsListFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    store.send(.toggleAllAgreements(!store.isAllAgreed))
                } label: {
                    HStack(spacing: 8) {
                        if store.isAllAgreed {
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
                        TypographyText(text: "약관 전체 동의", style: .b1_700, alignment: .left)
                        Spacer()
                    }
                    .clipShape(Rectangle())
                    .background(Color.gray0)
                }
                .buttonStyle(.plain)

                Divider()
                    .foregroundStyle(Color.gray50)
                    .padding(.vertical, 16)

                VStack(spacing: 12) {
                    ForEach(store.scope(state: \.agreeTermsRows, action: \.agreeTermsRows)) { rowStore in
                        WithPerceptionTracking {
                            AgreeTermsRowView(store: rowStore)
                        }
                    }
                }
            }
        }
    }
}
