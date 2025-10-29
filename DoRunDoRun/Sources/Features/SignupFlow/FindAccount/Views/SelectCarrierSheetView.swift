//
//  SelectCarrierSheetView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import SwiftUI

import ComposableArchitecture

struct SelectCarrierSheetView: View {
    let store: StoreOf<SelectCarrierFeature>
    var height: CGFloat = 349
    @GestureState private var dragOffset: CGFloat = 0
        
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Capsule()
                    .frame(width: 32, height: 5)
                    .foregroundStyle(Color.gray100)
                    .padding(.vertical, 16)
                
                VStack(alignment: .leading, spacing: 0) {
                    TypographyText(text: "통신사를 선택해주세요.", style: .t1_700)
                    
                    VStack(spacing: 16) {
                        ForEach(store.carriers, id: \.self) { carrier in
                            WithPerceptionTracking {
                                Button {
                                    store.send(.carrierTapped(carrier))
                                } label: {
                                    HStack {
                                        TypographyText(
                                            text: carrier,
                                            style: .b1_400,
                                            color: store.selectedCarrier == carrier ? .blue600 : .gray900
                                        )
                                        Spacer()
                                        if store.selectedCarrier == carrier {
                                            Image(.check, size: .medium)
                                                .renderingMode(.template)
                                                .foregroundStyle(Color.blue600)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 36)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.gray0)
            .clipShape(
                .rect(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .offset(y: max(dragOffset, 0))
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height >= 0 {
                            state = CGFloat(min(self.height, max(-self.height, value.translation.height)))
                        }
                    }
                    .onEnded { value in
                        if value.translation.height >= height/3 {
                            store.send(.dismissRequested)
                        }
                    }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
