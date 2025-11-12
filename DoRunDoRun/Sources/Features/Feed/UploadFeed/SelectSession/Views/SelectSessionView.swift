//
//  SelectSessionView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

import SwiftUI
import ComposableArchitecture

struct SelectSessionView: View {
    @Perception.Bindable var store: StoreOf<SelectSessionFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                serverErrorSection
                mainSection
                networkErrorPopupSection
            }
        }
    }
}

// MARK: - Server Error Section
private extension SelectSessionView {
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
private extension SelectSessionView {
    /// Main Seciton
    @ViewBuilder
    var mainSection: some View {
        if store.serverError.serverErrorType == nil {
            VStack(alignment: .leading, spacing: 32) {
                headerSection
                if store.isAnyCompleted {
                    certificationCompletedSection
                } else if store.sessions.isEmpty {
                    todaySessionEmptySection
                } else {
                    todaySessionListSection
                }
                Spacer()
                buttonSection
            }
            .padding(.horizontal, 20)
            .onAppear { store.send(.onAppear) }
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
            .navigationDestination(
                item: $store.scope(state: \.createFeed, action: \.createFeed)
            ) { store in
                CreateFeedView(store: store)
            }
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TypographyText(text: "러닝 내역", style: .t1_700)
            TypographyText(text: "오늘 달린 기록을 1회 인증할 수 있어요.", style: .b2_400)
        }
        .padding(.top, 16)
    }
    
    var certificationCompletedSection: some View {
        VStack(spacing: 24) {
            Image(.certificationCompleted)
                .resizable()
                .frame(width: 120, height: 120)
            VStack(spacing: 4) {
                TypographyText(text: "이미 인증을 완료했어요", style: .t2_700)
                TypographyText(text: "내일도 러닝하고 인증해요!", style: .b2_400)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    var todaySessionEmptySection: some View {
        VStack(spacing: 24) {
            Image(.empty2)
                .resizable()
                .frame(width: 120, height: 120)
            VStack(spacing: 4) {
                TypographyText(text: "인증 가능한 기록이 없어요..", style: .t2_700)
                TypographyText(text: "지금 바로 러닝을 시작해봐요!", style: .b2_400)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    var todaySessionListSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(store.sessions) { session in
                    Button {
                        store.send(.sessionTapped(session))
                    } label: {
                        SelectSessionRowView(
                            session: session,
                            isSelected: store.selectedSessionID == session.id
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var buttonSection: some View {
        AppButton(
            title: "불러오기",
            style: store.selectedSessionID != nil ? .primary : .disabled,
            size: .fullWidth
        ) {
            store.send(.loadButtonTapped)
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Network Error Popup Section
private extension SelectSessionView {
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
    SelectSessionView(
        store: .init(
            initialState: SelectSessionFeature.State(
                sessions: [
                    RunningSessionSummaryViewState(
                        id: 1,
                        date: Date(),
                        dateText: "2025.11.12 (수)",
                        timeText: "오전 8:45",
                        distanceText: "5.24km",
                        durationText: "00:32:10",
                        paceText: "6'08\"",
                        spmText: "174 spm",
                        tagStatus: .possible,
                        mapImageURL: nil
                    ),
                    RunningSessionSummaryViewState(
                        id: 2,
                        date: Date(),
                        dateText: "2025.11.11 (화)",
                        timeText: "오후 7:20",
                        distanceText: "7.80km",
                        durationText: "00:47:15",
                        paceText: "6'03\"",
                        spmText: "171 spm",
                        tagStatus: .possible,
                        mapImageURL: nil
                    )
                ],
                isLoading: false,
            ),
            reducer: { SelectSessionFeature() }
        )
    )
}
