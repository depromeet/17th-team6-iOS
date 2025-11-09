//
//  UploadFeedView.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 11/9/25.
//

import ComposableArchitecture
import SwiftUI

struct UploadFeedView: View {
    let store: StoreOf<UploadFeedFeature>
    var body: some View {
        WithPerceptionTracking {
            if store.isLoaded == false {
                ProgressView()
                Text("Loading..")

            } else {
                
            }
        }
        .onAppear {
            store.send(.fetchRunningRecords)
        }
    }
}

#Preview {
    UploadFeedView(store: .init(initialState: .init(), reducer: {
        UploadFeedFeature()
    }))
}
