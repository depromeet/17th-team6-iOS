//
//  EnterNameView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import SwiftUI

import ComposableArchitecture

struct EnterNameView: View {
    @Perception.Bindable var store: StoreOf<EnterNameFeature>

    var body: some View {
        WithPerceptionTracking {
            InputField(
                label: store.isNameEntered ? "이름" : nil,
                placeholder: "휴대폰 명의자 이름 입력",
                text: $store.name
            )
            .padding(.top, store.isNameEntered ? 24 : 32)
            .onChange(of: store.name) { store.send(.nameChanged($0)) }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
