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
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                VStack {
                    Spacer()
                    TabView(selection: $store.currentPage.sending(\.pageChanged)) {
                        ForEach(Array(store.pages.enumerated()), id: \.offset) { index, page in
                            OnboardingPageView(
                                image: Image(page.image),
                                title: page.title,
                                subtitle: page.subtitle
                            )
                            .tag(index)
                        }
                    }
                    .frame(height: 386)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: store.currentPage)
                    
                    OnboardingPageIndicator(currentPage: store.currentPage, totalCount: store.totalPages)
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
                switch store.case {
                case .termsAgreement(let store): AgreeTermsView(store: store)
                case .phoneAuth(let store): VerifyPhoneView(store: store)
                case .createProfile(let store): CreateProfileView(store: store)
                case .findAccount(let store): FindAccountView(store: store)
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
