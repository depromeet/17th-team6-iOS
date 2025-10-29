//
//  EnterBirthdateView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import SwiftUI

import ComposableArchitecture

struct EnterBirthdateView: View {
    @Perception.Bindable var store: StoreOf<EnterBirthdateFeature>

    var body: some View {
        WithPerceptionTracking {
            InputResidentNumberField(
                label: store.isBirthdateEntered ? "생년월일" : nil,
                placeholder: "생년월일",
                frontNumber: $store.birthdateFrontNumber,
                backFirstDigit: $store.birthdateBackFirstDigit
            )
            .padding(.top, store.isBirthdateEntered ? 24 : 32)
            .onChange(of: store.birthdateFrontNumber) { store.send(.frontChanged($0)) }
            .onChange(of: store.birthdateBackFirstDigit) { store.send(.backChanged($0)) }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
