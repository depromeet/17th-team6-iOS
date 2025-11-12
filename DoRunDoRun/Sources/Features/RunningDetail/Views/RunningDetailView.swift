//
//  RunningDetailView.swift
//  DoRunDoRun
//
//  Created by zaehorang on 10/29/25.
//

import SwiftUI

import ComposableArchitecture

struct RunningDetailView: View {
    @Perception.Bindable var store: StoreOf<RunningDetailFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                // MARK: - Main Content
                VStack(spacing: .zero) {
                    HStack(spacing: 4) {
                        Image("Fill_S")
                            .resizable()
                            .frame(width: 20, height: 20)
                        TypographyText(
                            text: store.detail.finishedAtText,
                            style: .b2_500, color: .gray700
                        )
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
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray50)
                    }
                    .padding(.bottom, 16)
                    
                    // ViewMode에 따라 이미지 or 지도
                    Group {
                        switch store.viewMode {
                        case .viewing:
                            // 과거 기록 보기: URL에서 이미지 로드
                            if let imageUrl = store.detail.mapImageURL {
                                squareRouteImage(url: imageUrl)
                            } else {
                                // URL이 없으면 빈 placeholder
                                placeholderMapView
                            }

                        case .completing:
                            // 방금 끝난 러닝: 지도에서 이미지 캡처
                            SquareRouteMap(
                                points: store.detail.points,
                                outerPadding: 20,
                                data: $store.detail.mapImageData)
                            .onAppear {
                                store.send(.startImageCapture)
                            }
                            .onChange(of: store.detail.mapImageData) { _ in
                                store.send(.getRouteImageData)
                            }
                        }
                    }
                    .cornerRadius(16)
                    .padding(.bottom, 8)
                    
                    paceColorBar
                    
                    Spacer()
                    
                    recordVerificationButton {
                        store.send(.recordVerificationButtonTapped)
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - Image Capture Dim Overlay (completing 모드에서만)
                if case .completing = store.viewMode, store.isCapturingImage {
                    ZStack {
                        Color.dimLight
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)

                            TypographyText(
                                text: "지도 이미지를 캡처하는 중...",
                                style: .b1_500,
                                color: .white
                            )
                        }
                    }
                    .transition(.opacity)
                    .zIndex(5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        store.send(.backButtonTapped)
                    } label: {
                        Image("Left_M")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
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
    }
    
    func recordVerificationButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Rectangle()
                    .foregroundColor(.gray100)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 2) {
                    TypographyText(text: "아직 인증하지 않았어요!", style: .b2_400, color: .gray500)
                    TypographyText(text: "이 기록 인증하러 가기", style: .t1_700, color: .blue600)
                }
                
                Spacer()
                
                Image("Arrow")
                    .padding(10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray50)
            }
        }
    }
    
    func squareRouteImage(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color.gray50
                    ProgressView()
                }

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                ZStack {
                    Color.gray50
                    TypographyText(
                        text: "이미지를 불러올 수 없어요",
                        style: .c1_400, color: .gray500
                    )
                }

            @unknown default:
                EmptyView()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview("Viewing Mode") {
    NavigationStack {
        RunningDetailView(
            store: Store(
                initialState: RunningDetailFeature.State(
                    detail: RunningDetailViewStateMapper.map(from: RunningDetail.mock),
                    viewMode: .viewing
                ),
                reducer: { RunningDetailFeature() }
            )
        )
    }
}

#Preview("Completing Mode") {
    NavigationStack {
        RunningDetailView(
            store: Store(
                initialState: RunningDetailFeature.State(
                    detail: RunningDetailViewStateMapper.map(from: RunningDetail.mock),
                    viewMode: .completing(sessionId: 123)
                ),
                reducer: { RunningDetailFeature() }
            )
        )
    }
}
