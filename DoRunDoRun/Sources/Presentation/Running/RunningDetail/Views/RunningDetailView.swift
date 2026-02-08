//
//  RunningDetailView.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/29/25.
//

import SwiftUI

import ComposableArchitecture
import Kingfisher

struct RunningDetailView: View {
    @Perception.Bindable var store: StoreOf<RunningDetailFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                // MARK: - Main Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Image(.distance, fill: .fill, size: .small)
                                .renderingMode(.template)
                                .foregroundStyle(Color.blue600)
                            TypographyText(text: store.detail.startedAtText, style: .b2_500, color: .gray700)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 16)

                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: .zero) {
                                    TypographyText(text: "달린 거리", style: .c1_400, color: .gray500)
                                    TypographyText(text: store.detail.totalDistanceText, style: .h1_700, color: .gray900)
                                }
                                VStack(alignment: .leading, spacing: .zero) {
                                    TypographyText(text: "평균 페이스", style: .c1_400, color: .gray500)
                                    TypographyText(text: store.detail.avgPaceText, style: .t1_700, color: .gray900)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: .zero) {
                                    TypographyText(text: "달린 시간", style: .c1_400, color: .gray500)
                                    TypographyText(text: store.detail.durationText, style: .h1_700, color: .gray900)
                                }
                                VStack(alignment: .leading, spacing: .zero) {
                                    TypographyText(text: "평균 케이던스", style: .c1_400, color: .gray500)
                                    TypographyText(text: store.detail.cadenceText, style: .t1_700, color: .gray900)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.gray50)
                        .cornerRadius(16)
                        .padding(.bottom, 16)

                        SquareRouteMap(
                            points: store.detail.points,
                            outerPadding: 20,
                            data: $store.detail.mapImageData
                        )
                        .onAppear {
                            store.send(.startImageCapture)
                        }
                        .onChange(of: store.detail.mapImageData) { _ in
                            store.send(.getRouteImageData)
                        }
                        .cornerRadius(16)

                        paceColorBar

                        if store.isUploadable {
                            recordVerificationButton {
                                store.send(.recordVerificationButtonTapped)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // MARK: - Image Capture Dim Overlay
                if store.detail.mapImageURL == nil,
                   store.isCapturingImage {
                    ZStack {
                        Color.dimLight
                            .ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.gray0))
                            .scaleEffect(1.5)
                    }
                    .transition(.opacity)
                    .zIndex(5)
                }
            }
            .onAppear { store.send(.onAppear) }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
            .navigationDestination(
                item: $store.scope(state: \.createFeed, action: \.createFeed)
            ) { store in
                CreateFeedView(store: store)
            }

            // MARK: - Error Handling
            .errorHandling(
                networkErrorPopupStore: store.scope(
                    state: \.networkErrorPopup,
                    action: \.networkErrorPopup
                ),
                serverErrorStore: store.scope(
                    state: \.serverError,
                    action: \.serverError
                ),
                onNetworkRetry: {
                    store.send(.networkErrorPopup(.retryButtonTapped))
                },
                onServerRetry: {
                    store.send(.serverError(.retryButtonTapped))
                }
            )
        }
    }
}

// MARK: - UI Components
private extension RunningDetailView {
    var placeholderMapView: some View {
        ZStack {
            Color.gray50
            TypographyText(
                text: "지도 이미지가 없습니다",
                style: .b1_500,
                color: .gray500
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    var paceColorBar: some View {
        HStack(alignment: .center, spacing: 8) {
            TypographyText(text: "빠름", style: .b2_700, color: .blue600)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 8)
                .background(
                    LinearGradient(
                        stops: [
                            // 파(빠름) → 연녹 → 노 → 주 → 빨(느림)
                            .init(color: Color(red: 0.28, green: 0.32, blue: 1.00), location: 0.00), // 파랑
                            .init(color: Color(red: 0.15, green: 1.00,  blue: 0.00), location: 0.25), // 연녹
                            .init(color: Color(red: 1.00, green: 0.84, blue: 0.00), location: 0.50), // 노랑
                            .init(color: Color(red: 1.00, green: 0.48, blue: 0.00), location: 0.75), // 주황
                            .init(color: Color(red: 1.00, green: 0.00, blue: 0.00), location: 1.00)  // 빨강
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
    
    func recordVerificationButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
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
    
    func squareRouteImage(url: URL) -> some View {
        KFImage(url)
            .placeholder {
                ZStack {
                    Color.gray50
                    ProgressView()
                }
            }
            .onFailure { error in
                print("⚠️ Failed to load image: \(error)")
            }
            .resizable()
            .scaledToFill()
            .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RunningDetailView(
            store: Store(
                initialState: RunningDetailFeature.State(
                    detail: RunningDetailViewStateMapper.map(from: RunningDetail.mock),
                ),
                reducer: { RunningDetailFeature() }
            )
        )
    }
}
