//
//  FeedCertificationListView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI
import ComposableArchitecture

struct FeedCertificationListView: View {
    @Perception.Bindable var store: StoreOf<FeedCertificationListFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                mainSection
            }
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

// MARK: - Main Section
private extension FeedCertificationListView {
    /// Main Secition
    @ViewBuilder
    var mainSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            certificationUserListSection
            Spacer()
        }
    }

    /// 헤더 섹션
    var headerSection: some View {
        HStack(spacing: 8) {
            TypographyText(text: "인증목록", style: .t1_700, color: .gray800)
            TypographyText(text: "\(store.users.count)", style: .t1_700, color: .gray500)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 인증 유저 목록 섹션
    var certificationUserListSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.users) { user in
                    FeedCertificationListRowView(user: user) {
                        store.send(.userTapped(user.id))
                    }
                }
            }
        }
    }
}
