//
//  FindAccountView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI
import WebKit

import ComposableArchitecture

struct FindAccountView: View {
    let store: StoreOf<FindAccountFeature>

    var body: some View {
        WithPerceptionTracking {
            WebView(url: store.url)
                .ignoresSafeArea()
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

// 간단한 WebView Wrapper
struct WebView: UIViewRepresentable {
    let url: URL?

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url else { return }
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }
}


// MARK: - Preview
#Preview {
    FindAccountView(
        store: Store(initialState: FindAccountFeature.State()) {
            FindAccountFeature()
        }
    )
}
