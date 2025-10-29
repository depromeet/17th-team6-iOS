//
//  EnterVerificationCodeView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/26/25.
//

import SwiftUI

import ComposableArchitecture

struct EnterVerificationCodeView: View {
    @Perception.Bindable var store: StoreOf<EnterVerificationCodeFeature>

    var body: some View {
        WithPerceptionTracking {
            InputVerificationCodeField(
                code: $store.verificationCode,
                timerText: store.timer.timerText,
                onResend: { store.send(.resendTapped) }
            )
            .padding(.top, 32)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

