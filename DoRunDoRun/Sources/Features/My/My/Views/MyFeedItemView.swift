//
//  MyFeedItemView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI
import Kingfisher

struct MyFeedItemView: View {
    let item: SelfieFeedItem
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack(alignment: .center) {
                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                    KFImage(url)
                        .placeholder {
                            Rectangle()
                                .fill(Color.gray100)
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                                .cornerRadius(8)
                        }
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray100)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .cornerRadius(8)
                }
                
                TypographyText(text: item.dayText, style: .t1_500, color: .gray0)
            }

        }
    }
}
