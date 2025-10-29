//
//  OnboardingView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    @Perception.Bindable var store: StoreOf<OnboardingFeature>
    
    // 온보딩 페이지 데이터 (이미지, 타이틀, 서브타이틀)
    private let pages: [(image: String, title: String, subtitle: String)] = [
        (
            "onboarding_1",
            "함께라면 두런두런 즐겁게!",
            "혼자서는 어려운 러닝, 친구와 함께 달리며\n습관으로 만들어보세요."
        ),
        (
            "onboarding_2",
            "친구들의 러닝 현황을 확인해요",
            "지도에 표시된 친구들의 러닝 현황을 보며\n멀리서도 함께 뛰는 기분을 느껴요."
        ),
        (
            "onboarding_3",
            "오늘의 러닝, 피드에 인증해요",
            "오늘의 러닝을 피드에 남기고,\n친구와 리액션을 주고받으며 함께 달려요."
        )
    ]
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                // Root view of the navigation stack
                VStack {
                    Spacer()
                    TabView(selection: $store.currentPage.sending(\.pageChanged)) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            OnboardingPageView(imageName: page.image, title: page.title, subtitle: page.subtitle)
                            .tag(index)
                        }
                    }
                    .frame(height: 386)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: store.currentPage)
                    
                    OnboardingPageIndicator(currentPage: store.currentPage, totalCount: pages.count)
                    .padding(.top, 40)
                    
                    Spacer()
                    VStack(spacing: 12) {
                        AppButton(title: "회원가입") {
                            store.send(.signupButtonTapped)
                        }
                        AppButton(title: "이미 가입했나요? 로그인", style: .text, underlineTarget: "로그인") {
                            store.send(.loginButtonTapped)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            } destination: { store in
                // A view for each case of the Path.State enum
                switch store.case {
                case .termsAgreement(let store): AgreeTermsView(store: store)
                case .phoneAuth(let store): VerifyPhoneView(store: store)
                case .createProfile(let store): CreateProfileView(store: store)
                case .findAccount(let store): FindAccountView(store: store)
                case .accountCheck(let store): CheckAccountView(store: store)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    )
}
