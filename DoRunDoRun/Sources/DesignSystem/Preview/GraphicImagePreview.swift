//
//  GraphicImagePreview.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/2/25.
//

import SwiftUI

struct GraphicImagePreview: View {
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 16)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                // MARK: - Running
                Section(header: sectionHeader("Running")) {
                    previewItem(.runningStart)
                    previewItem(.runningVerified)
                    previewItem(.runningRecordBanner)
                }
                
                // MARK: - Emoji
                Section(header: sectionHeader("Emoji")) {
                    previewItem(.emojiSurprised)
                    previewItem(.emojiHeart)
                    previewItem(.emojiFire)
                    previewItem(.emojiThumbsup)
                    previewItem(.emojiCongrats)
                }
                
                // MARK: - Empty
                Section(header: sectionHeader("Empty")) {
                    previewItem(.empty1)
                    previewItem(.empty2)
                }
                
                // MARK: - Error
                Section(header: sectionHeader("Error")) {
                    previewItem(.error)
                }
                
                // MARK: - Notification
                Section(header: sectionHeader("Notification")) {
                    previewItem(.notification1)
                    previewItem(.notification2)
                    previewItem(.notification3)
                }
                
                // MARK: - Onboarding
                Section(header: sectionHeader("Onboarding")) {
                    previewItem(.onboarding1)
                    previewItem(.onboarding2)
                    previewItem(.onboarding3)
                }
                
                // MARK: - Others
                Section(header: sectionHeader("Others")) {
                    previewItem(.profilePlaceholder)
                    previewItem(.friendMarker)
                }
            }
            .padding(20)
        }
        .navigationTitle("Graphic Preview")
    }
    
    // MARK: - Subviews
    private func previewItem(_ graphic: GraphicStyle) -> some View {
        VStack(spacing: 8) {
            Image(graphic)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text(graphic.rawValue)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        GraphicImagePreview()
    }
}
