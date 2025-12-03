//
//  SplashView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    let store: StoreOf<SplashFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color.blue600
                    .ignoresSafeArea()
                
                Image("SplashLogo")
                    .scaleEffect(store.isFinished ? 1.1 : 1.0)
                    .opacity(store.isFinished ? 0 : 1)
                    .animation(.easeInOut(duration: 0.8), value: store.isFinished)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
