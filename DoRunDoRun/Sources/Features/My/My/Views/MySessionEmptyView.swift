//
//  MySessionEmptyView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import SwiftUI

struct MySessionEmptyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Empty 이미지
            Image(.empty2)
                .resizable()
                .frame(width: 120, height: 120)
            
            // Empty 텍스트
            VStack(spacing: 4) {
                TypographyText(text: "아직 러닝 기록이 없어요...", style: .t2_700, color: .gray900)
                TypographyText(text: "지금 바로 러닝을 시작해봐요!", style: .b2_400, color: .gray700)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
