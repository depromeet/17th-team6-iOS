//
//  EnterPhoneNumberView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import SwiftUI

import ComposableArchitecture

struct EnterPhoneNumberView: View {
    @Perception.Bindable var store: StoreOf<EnterPhoneNumberFeature>

    var body: some View {
        WithPerceptionTracking {
            InputField(
                keyboardType: .numberPad,
                label: store.isPhoneNumberEntered ? "휴대폰 번호" : nil,
                placeholder: "휴대폰 번호를 입력하세요",
                text: $store.phoneNumber
            )
            .padding(.top, store.isPhoneNumberEntered ? 24 : 32)
            .onChange(of: store.phoneNumber) { store.send(.phoneNumberChanged($0)) }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

