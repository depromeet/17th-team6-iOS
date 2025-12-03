//
//  SettingWebView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/14/25.
//

import SwiftUI
import ComposableArchitecture

struct SettingWebView: View {
    let store: StoreOf<SettingWebFeature>

    var body: some View {
        WithPerceptionTracking {
            WebView(url: URL(string: store.urlString)!)
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
