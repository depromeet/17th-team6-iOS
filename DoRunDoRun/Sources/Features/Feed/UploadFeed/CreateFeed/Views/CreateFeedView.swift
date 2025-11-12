//
//  CreateFeedView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture
import Kingfisher

struct CreateFeedView: View {
    @Perception.Bindable var store: StoreOf<CreateFeedFeature>
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
        }
    }
}

// MARK: - Server Error Section
private extension CreateFeedView {
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
private extension CreateFeedView {
    /// Main Section
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(spacing: 12) {
                feedImageSection
                selectImageButton
                Spacer()
                uploadButton
            }
            .padding(.horizontal, 20)
            .scrollDisabled(true)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.saveImageButtonTapped)
                    } label: {
                        Image(.download, size: .medium)
                            .renderingMode(.template)
                            .foregroundColor(.gray800)
                    }
                }
            }
        }
    }
    
    /// 피드 이미지 섹션
    var feedImageSection: some View {
        ZStack(alignment: .bottom) {
            // 사용자가 선택한 이미지
            if let selectedImage = store.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .cornerRadius(16)
                    .clipped()

            // 러닝 세션의 지도 이미지(mapImageURL)
            } else if let urlString = store.session.mapImageURL,
                      let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray100)
                            .frame(width: UIScreen.main.bounds.width - 40,
                                   height: UIScreen.main.bounds.width - 40)
                            .cornerRadius(16)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .cornerRadius(16)
                    .clipped()

            // 기본 회색 배경
            } else {
                Rectangle()
                    .fill(Color.gray100)
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .cornerRadius(16)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(.camera)
                                .renderingMode(.template)
                                .foregroundColor(.gray400)
                            TypographyText(text: "배경사진을 추가해보세요", style: .b2_400, color: .gray500)
                        }
                    }
            }

            // 달리기 정보 오버레이
            runningInfoOverlay
        }
        .padding(.top, 40)
    }

    /// 달리기 정보 오버레이
    var runningInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                TypographyText(text: store.session.dateText, style: .c1_400, color: .gray0)
                TypographyText(text: "·", style: .c1_400, color: .gray0)
                TypographyText(text: store.session.timeText, style: .c1_400, color: .gray0)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.dimLight)
            .clipShape(.capsule)
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                HStack {
                    metricRow(title: "달린 거리", value: store.session.distanceText)
                    metricRow(title: "달린 시간", value: store.session.durationText)
                }
                HStack {
                    metricRow(title: "평균 페이스", value: store.session.paceText)
                    metricRow(title: "평균 케이던스", value: store.session.spmText)
                }
            }
            .padding(.top, 80)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: 0x000000, alpha: 0.8),
                        Color(hex: 0x000000, alpha: 0.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .cornerRadius(16)
            )
        }
        .frame(width: UIScreen.main.bounds.width - 40,
               height: UIScreen.main.bounds.width - 40)
    }
    
    /// 공통 메트릭 행
    func metricRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            TypographyText(text: title, style: .c1_400, color: .gray0)
            TypographyText(text: value, style: .h1_700, color: .gray0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// 이미지 선택 버튼
    var selectImageButton: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            TypographyText(text: "배경사진 변경", style: .b1_700, color: .blue600)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.blue200)
                .cornerRadius(10)
        }
        .padding(.top, 12)
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    store.send(.imageDataPicked(data))
                }
            }
        }
    }
    
    /// 업로드 버튼
    var uploadButton: some View {
        AppButton(title: "게시물 올리기", style: .primary, size: .fullWidth) {
            store.send(.uploadButtonTapped)
        }
        .disabled(store.isUploading)
        .padding(.bottom, 24)
    }
}

// MARK: - Network Error Popup Section
private extension CreateFeedView {
    /// Network Error Popup Section
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

// MARK: - Preview
#Preview {
    CreateFeedView(
        store: .init(
            initialState: CreateFeedFeature.State(
                session: RunningSessionSummaryViewState(
                    id: 1,
                    date: Date(),
                    dateText: "2025.11.12 (수)",
                    timeText: "오전 9:15",
                    distanceText: "5.24km",
                    durationText: "00:32:10",
                    paceText: "6'08\"",
                    spmText: "174 spm",
                    tagStatus: .possible,
                    mapImageURL: nil
                )
            ),
            reducer: { CreateFeedFeature() }
        )
    )
}
