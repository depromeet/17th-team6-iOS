//
//  MySessionDetailView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct MySessionDetailView: View {
    @Perception.Bindable var store: StoreOf<MySessionDetailFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
            .onAppear { store.send(.onAppear) }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { store.send(.backButtonTapped) } label: {
                        Image(.arrowLeft, size: .medium)
                            .renderingMode(.template)
                            .foregroundStyle(Color.gray800)
                    }
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.myFeedDetail, action: \.myFeedDetail)
            ) { store in
                MyFeedDetailView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.createFeed, action: \.createFeed)
            ) { store in
                CreateFeedView(store: store)
            }
        }
    }
}

// MARK: - Server Error Section
private extension MySessionDetailView {
    /// Server Error Section
    @ViewBuilder
    var serverErrorSection: some View {
        if let serverErrorType = store.serverError.serverErrorType {
            ServerErrorView(serverErrorType: serverErrorType) {
                store.send(.serverError(.retryButtonTapped))
            }
        }
    }
}

// MARK: - Main Section
private extension MySessionDetailView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            ScrollView {
                if let detail = store.detail {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection(detail)
                        summarySection(detail)
                        mapSection(detail)
                        paceColorBar

                        // MARK: CTA 조건
                        if detail.feed != nil {
                            verificationCompletedCTA(
                                selfieImageURL: detail.feed?.selfieImageURL
                            ) {
                                store.send(.verificationCompletedButtonTapped)
                            }
                        } else if let uploadable = store.uploadable,
                                  uploadable.isUploadable {
                            verificationPossibleCTA {
                                store.send(.verificationPossibleButtonTapped)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                } else {
                    // detail 로딩 중 상태
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
    }
    
    /// 헤더 섹션
    func headerSection(_ detail: RunningDetailViewState) -> some View {
        HStack(spacing: 4) {
            Image(.distance, fill: .fill, size: .small)
                .renderingMode(.template)
                .foregroundStyle(Color.blue600)
            TypographyText(text: detail.startedAtText, style: .b2_500, color: .gray700)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
    }

   /// 요약 정보 섹션
    func summarySection(_ detail: RunningDetailViewState) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                infoBlock(title: "달린 거리", value: detail.totalDistanceText, large: true)
                infoBlock(title: "평균 페이스", value: detail.avgPaceText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                infoBlock(title: "달린 시간", value: detail.durationText, large: true)
                infoBlock(title: "평균 케이던스", value: detail.cadenceText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.gray50)
        .cornerRadius(16)
        .padding(.bottom, 16)
    }
    
    /// 정보 블럭
    func infoBlock(title: String, value: String, large: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            TypographyText(text: title, style: .c1_400, color: .gray500)
            TypographyText(
                text: value,
                style: large ? .h1_700 : .t1_700,
                color: .gray900
            )
        }
    }

    /// 지도 이미지 섹션
    @ViewBuilder
    func mapSection(_ detail: RunningDetailViewState) -> some View {
        if let url = detail.mapImageURL {
            KFImage(url)
                .placeholder {
                    ZStack {
                        Color.gray50
                        ProgressView()
                    }
                }
                .resizable()
                .scaledToFit()
                .cornerRadius(16)

        } else {
            ZStack {
                Color.gray50
                TypographyText(text: "지도 이미지가 없습니다", style: .b1_500, color: .gray500)
            }
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(16)
        }
    }

    /// 페이스 컬러 바
    var paceColorBar: some View {
        HStack(spacing: 8) {
            TypographyText(text: "빠름", style: .b2_700, color: .blue600)
            Rectangle()
                .frame(height: 8)
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.28, green: 0.32, blue: 1.00),
                            Color(red: 0.15, green: 1.00, blue: 0.00),
                            Color(red: 1.00, green: 0.84, blue: 0.00),
                            Color(red: 1.00, green: 0.48, blue: 0.00),
                            Color(red: 1.00, green: 0.00, blue: 0.00)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(41)
            TypographyText(text: "느림", style: .b2_700, color: .paceRed)
        }
        .padding(.top, 8)
        .padding(.bottom, 32)
    }
}

// MARK: - CTA Components
private extension MySessionDetailView {
    /// 인증 가능 CTA
    func verificationPossibleCTA(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(.runningRecordBanner)
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 2) {
                    TypographyText(text: "아직 인증하지 않았어요!", style: .b2_400, color: .gray500)
                    TypographyText(text: "이 기록 인증하러 가기", style: .t1_700, color: .blue600)
                }
                
                Spacer()
                
                Image(.arrowRight, size: .medium)
                    .padding(10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.gray50)
            .cornerRadius(16)
        }
    }
    
    /// 인증 완료 CTA
    func verificationCompletedCTA(
        selfieImageURL: URL?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    TypographyText(text: "인증을 완료했어요!", style: .b2_400, color: .gray500)
                    TypographyText(text: "인증 게시물 보러가기", style: .t1_700, color: .blue600)
                }
                Spacer()
                
                if let url = selfieImageURL {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray100)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.gray50)
            .cornerRadius(16)
        }
    }
}

// MARK: - Network Error Popup Section
private extension MySessionDetailView {
    /// Networ Error Popup Section
    @ViewBuilder
    var networkErrorPopupSection: some View {
        if store.networkErrorPopup.isVisible {
            ZStack {
                Color.dimLight
                    .ignoresSafeArea()
                NetworkErrorPopupView {
                    store.send(.networkErrorPopup(.retryButtonTapped))
                }
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(10)
        }
    }
}
