//
//  AgreeTermsSheetView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import SwiftUI

import ComposableArchitecture

struct AgreeTermsSheetView: View {
    let store: StoreOf<AgreeTermsFeature>
    var height: CGFloat = 433
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Capsule()
                    .frame(width: 32, height: 5)
                    .foregroundStyle(Color.gray100)
                    .padding(.vertical, 16)
            
                VStack(alignment: .leading, spacing: 0) {
                    TypographyText(
                        text: "본인인증을 위해 동의해주세요.",
                        style: .t1_700,
                        alignment: .left
                    )
                    
                    AgreeTermsListView(
                        store: store.scope(state: \.agreeTermsList, action: \.agreeTermsList)
                    )
                    .padding(.top, 24)
                    
                    AppButton(
                        title: "동의하고 계속하기",
                        style: store.isEssentialAgreed ? .primary : .disabled
                    ) {
                        store.send(.bottomButtonTapped)
                    }
                    .padding(.top, 36)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.gray0)
            .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .offset(y: max(dragOffset, 0))
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height >= 0 {
                            state = min(self.height, value.translation.height)
                        }
                    }
                    .onEnded { value in
                        if value.translation.height >= 150 {
                            store.send(.dismissRequested)
                        }
                    }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
