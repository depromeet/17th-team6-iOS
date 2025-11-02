//
//  OnboardingFeature.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/21/25.
//

import Foundation

import ComposableArchitecture

struct OnboardingPage: Equatable {
    let image: GraphicStyle
    let title: String
    let subtitle: String
}

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State {
        var pages: [OnboardingPage] = [
            OnboardingPage(
                image: .onboarding1,
                title: "함께라면 두런두런 즐겁게!",
                subtitle: "혼자서는 어려운 러닝, 친구와 함께 달리며\n습관으로 만들어보세요."
            ),
            OnboardingPage(
                image: .onboarding2,
                title: "친구들의 러닝 현황을 확인해요",
                subtitle: "지도에 표시된 친구들의 러닝 현황을 보며\n멀리서도 함께 뛰는 기분을 느껴요."
            ),
            OnboardingPage(
                image: .onboarding3,
                title: "오늘의 러닝, 피드에 인증해요",
                subtitle: "오늘의 러닝을 피드에 남기고,\n친구와 리액션을 주고받으며 함께 달려요."
            )
        ]
        var currentPage = 0
        let totalPages = 3
        var path = StackState<Path.State>()
        
        var marketingConsentAt: Date? = nil
        var locationConsentAt: Date = Date()
        var personalConsentAt: Date = Date()
    }

    enum Action {
        // 내부 동작
        case nextPage
        case previousPage
        case pageChanged(Int)
        
        // 버튼 액션
        case signupButtonTapped
        case loginButtonTapped
        
        // 네비게이션 경로
        case path(StackActionOf<Path>)
        
        // 상위 피처에서 처리
        case finished
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            // MARK: - 온보딩 내부 동작 (페이지 전환)
            case .nextPage:
                if state.currentPage < state.totalPages - 1 {
                    state.currentPage += 1
                }
                return .none

            case .previousPage:
                if state.currentPage > 0 {
                    state.currentPage -= 1
                }
                return .none

            case let .pageChanged(index):
                state.currentPage = index
                return .none

            // MARK: - 버튼 액션
            case .signupButtonTapped:
                // 회원가입 버튼 → 약관 동의 화면으로 이동
                state.path.append(.termsAgreement(AgreeTermsFeature.State(type: .signUp)))
                return .none

            case .loginButtonTapped:
                // 로그인 버튼 → 휴대폰 인증(로그인 모드) 화면으로 이동
                state.path.append(.phoneAuth(VerifyPhoneFeature.State(mode: .login)))
                return .none

            // MARK: - 자식 피처 액션 감지
            case let .path(.element(id: id, action: .termsAgreement(.completed))):
                guard let element = state.path[id: id],
                      case let .termsAgreement(termsState) = element else {
                    return .none
                }
                
                let now = Date()
                if termsState.agreeTermsList.isMarketingAgreed {
                    state.marketingConsentAt = now
                }
                state.locationConsentAt = now
                state.personalConsentAt = now
                
                // 약관 동의 완료 → 휴대폰 인증(회원가입 모드) 화면으로 이동
                state.path.append(.phoneAuth(VerifyPhoneFeature.State(mode: .signup)))
                return .none
                
            case .path(.element(id: _, action: .termsAgreement(.backButtonTapped))):
                state.path.removeAll()
                return .none
                
            case let .path(.element(id: id, action: .phoneAuth(.completed(phoneNumber)))):
                // 휴대폰 인증 완료 → 회원가입 or 로그인 흐름 분기
                if let element = state.path[id: id],
                   case let .phoneAuth(phoneAuthState) = element {
                    if phoneAuthState.mode == .signup {
                        // 회원가입 모드 → 프로필 생성 화면으로 이동
                        state.path.append(.createProfile(CreateProfileFeature.State(
                            verifiedPhoneNumber: phoneNumber,
                            marketingConsentAt: state.marketingConsentAt,
                            locationConsentAt: state.locationConsentAt,
                            personalConsentAt: state.personalConsentAt
                        )))
                    } else {
                        // 로그인 모드 → 온보딩 완료
                        return .send(.finished)
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .phoneAuth(.signupButtonTapped))):
                // 로그인 화면에서 회원가입 버튼 → 약관동의 화면으로 이동 (기존 스택 초기화)
                state.path = StackState([.termsAgreement(AgreeTermsFeature.State(type: .signUp))])
                return .none
                
            case .path(.element(id: _, action: .phoneAuth(.findAccountButtonTapped))):
                // 로그인 화면에서 계정찾기 버튼 → 계정찾기 화면으로 이동
                state.path.append(.findAccount(FindAccountFeature.State()))
                return .none
                
            case let .path(.element(id: id, action: .phoneAuth(.backButtonTapped))):
                if let element = state.path[id: id],
                   case let .phoneAuth(phoneAuthState) = element {
                    switch phoneAuthState.mode {
                    case .signup:
                        // 회원가입 흐름: 약관 동의로 돌아감 (현재 화면 pop)
                        state.path.removeLast()
                    case .login:
                        // 로그인 흐름: 온보딩 첫 화면으로 돌아감 (전체 스택 제거)
                        state.path.removeAll()
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .findAccount(.backButtonTapped))):
                state.path.removeLast()
                return .none
                
            case .path(.element(id: _, action: .createProfile(.completed))):
                // 프로필 생성 완료 → 온보딩 완료
                return .send(.finished)
                
            case .path(.element(id: _, action: .createProfile(.backButtonTapped))):
                state.path.removeLast()
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    // MARK: - 네비게이션 경로 정의
    @Reducer
    enum Path {
        case termsAgreement(AgreeTermsFeature)
        case phoneAuth(VerifyPhoneFeature)
        case createProfile(CreateProfileFeature)
        case findAccount(FindAccountFeature)
    }
}
