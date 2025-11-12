//
//  View+ErrorHandling.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/11/25.
//

import SwiftUI

import ComposableArchitecture

extension View {
    /// 네트워크 에러 팝업과 서버 에러 전체 화면을 자동으로 처리하는 Modifier
    ///
    /// - Parameters:
    ///   - networkErrorPopupStore: NetworkErrorPopupFeature의 Store
    ///   - serverErrorStore: ServerErrorFeature의 Store
    ///   - onNetworkRetry: 네트워크 에러 재시도 버튼 탭 시 실행할 클로저
    ///   - onServerRetry: 서버 에러 재시도 버튼 탭 시 실행할 클로저
    ///
    /// - Returns: 에러 처리가 추가된 View
    ///
    /// # 사용 예시
    /// ```swift
    /// var body: some View {
    ///     WithPerceptionTracking {
    ///         contentView
    ///     }
    ///     .errorHandling(
    ///         networkErrorPopupStore: store.scope(state: \.networkErrorPopup, action: \.networkErrorPopup),
    ///         serverErrorStore: store.scope(state: \.serverError, action: \.serverError),
    ///         onNetworkRetry: { store.send(.networkErrorPopup(.retryButtonTapped)) },
    ///         onServerRetry: { store.send(.serverError(.retryButtonTapped)) }
    ///     )
    /// }
    /// ```
    func errorHandling(
        networkErrorPopupStore: Store<NetworkErrorPopupFeature.State, NetworkErrorPopupFeature.Action>,
        serverErrorStore: Store<ServerErrorFeature.State, ServerErrorFeature.Action>,
        onNetworkRetry: @escaping () -> Void,
        onServerRetry: @escaping () -> Void
    ) -> some View {
        ZStack {
            // 기본 컨텐츠 (서버 에러가 있으면 숨김)
            self
                .opacity(serverErrorStore.withState { $0.serverErrorType == nil } ? 1 : 0)

            // 서버 에러 전체 화면 (최우선 표시)
            if let serverErrorType = serverErrorStore.withState({ $0.serverErrorType }) {
                ServerErrorView(serverErrorType: serverErrorType) {
                    onServerRetry()
                }
            }

            // 네트워크 에러 팝업 (오버레이)
            if networkErrorPopupStore.withState({ $0.isVisible }) {
                ZStack {
                    Color.dimLight
                        .ignoresSafeArea()
                    NetworkErrorPopupView {
                        onNetworkRetry()
                    }
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(10)
            }
        }
    }
}

// MARK: - Preview

#Preview("정상 상태") {
    SampleContentView()
        .errorHandling(
            networkErrorPopupStore: Store(
                initialState: NetworkErrorPopupFeature.State(isVisible: false),
                reducer: { NetworkErrorPopupFeature() }
            ),
            serverErrorStore: Store(
                initialState: ServerErrorFeature.State(isVisible: false, serverErrorType: nil),
                reducer: { ServerErrorFeature() }
            ),
            onNetworkRetry: { print("Network retry tapped") },
            onServerRetry: { print("Server retry tapped") }
        )
}

#Preview("네트워크 에러 팝업") {
    SampleContentView()
        .errorHandling(
            networkErrorPopupStore: Store(
                initialState: NetworkErrorPopupFeature.State(isVisible: true),
                reducer: { NetworkErrorPopupFeature() }
            ),
            serverErrorStore: Store(
                initialState: ServerErrorFeature.State(isVisible: false, serverErrorType: nil),
                reducer: { ServerErrorFeature() }
            ),
            onNetworkRetry: { print("Network retry tapped") },
            onServerRetry: { print("Server retry tapped") }
        )
}

#Preview("서버 에러 - 404") {
    SampleContentView()
        .errorHandling(
            networkErrorPopupStore: Store(
                initialState: NetworkErrorPopupFeature.State(isVisible: false),
                reducer: { NetworkErrorPopupFeature() }
            ),
            serverErrorStore: Store(
                initialState: ServerErrorFeature.State(isVisible: true, serverErrorType: .notFound),
                reducer: { ServerErrorFeature() }
            ),
            onNetworkRetry: { print("Network retry tapped") },
            onServerRetry: { print("Server retry tapped") }
        )
}

#Preview("서버 에러 - 500") {
    SampleContentView()
        .errorHandling(
            networkErrorPopupStore: Store(
                initialState: NetworkErrorPopupFeature.State(isVisible: false),
                reducer: { NetworkErrorPopupFeature() }
            ),
            serverErrorStore: Store(
                initialState: ServerErrorFeature.State(isVisible: true, serverErrorType: .internalServer),
                reducer: { ServerErrorFeature() }
            ),
            onNetworkRetry: { print("Network retry tapped") },
            onServerRetry: { print("Server retry tapped") }
        )
}

#Preview("서버 에러 - 502") {
    SampleContentView()
        .errorHandling(
            networkErrorPopupStore: Store(
                initialState: NetworkErrorPopupFeature.State(isVisible: false),
                reducer: { NetworkErrorPopupFeature() }
            ),
            serverErrorStore: Store(
                initialState: ServerErrorFeature.State(isVisible: true, serverErrorType: .badGateway),
                reducer: { ServerErrorFeature() }
            ),
            onNetworkRetry: { print("Network retry tapped") },
            onServerRetry: { print("Server retry tapped") }
        )
}

// MARK: - Sample Content View for Preview

private struct SampleContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 헤더
                    HStack {
                        Image(systemName: "figure.run")
                            .resizable()
                            .frame(width: 24, height: 24)
                        TypographyText(text: "러닝 기록", style: .h1_700, color: .gray900)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 16)

                    // 통계 카드
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            TypographyText(text: "달린 거리", style: .c1_400, color: .gray500)
                            TypographyText(text: "5.2 km", style: .h1_700, color: .gray900)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 8) {
                            TypographyText(text: "달린 시간", style: .c1_400, color: .gray500)
                            TypographyText(text: "32:15", style: .h1_700, color: .gray900)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray50)
                    }

                    // 지도 영역
                    Rectangle()
                        .fill(Color.gray100)
                        .frame(height: 300)
                        .cornerRadius(16)
                        .overlay {
                            TypographyText(text: "지도 영역", style: .b1_500, color: .gray500)
                        }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        print("Back button tapped")
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}
