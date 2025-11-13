//
//  AgreeTermsWebView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/14/25.
//

import SwiftUI
import WebKit

import ComposableArchitecture

struct AgreeTermsWebView: View {
    let store: StoreOf<AgreeTermsWebFeature>
    
    var body: some View {
        WithPerceptionTracking {
            WebView(url: store.url)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            store.send(.backButtonTapped)
                        } label: {
                            Image(.arrowLeft, size: .medium)
                                .renderingMode(.template)
                                .foregroundColor(.gray800)
                        }
                    }
                }
        }
    }
}

