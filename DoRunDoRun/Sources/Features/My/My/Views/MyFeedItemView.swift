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
                    // 피드 이미지가 있을 경우 해당 이미지 노출
                    KFImage(url)
                        .placeholder {
                            Rectangle()
                                .fill(Color.gray100)
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                                .cornerRadius(8)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: (UIScreen.main.bounds.width - 48) / 3,
                               height: (UIScreen.main.bounds.width - 48) / 3)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    // 피드 이미지가 없을 경우 기본 회색 배경
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
