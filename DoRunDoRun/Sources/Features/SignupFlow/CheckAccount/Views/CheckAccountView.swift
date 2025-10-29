//
//  CheckAccountView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/22/25.
//

import SwiftUI

import ComposableArchitecture

struct CheckAccountView: View {
    let store: StoreOf<CheckAccountFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.status {
                case .loading:
                    loadingView
                case .loaded:
                    loadedView
                case .failed:
                    failedView
                }
            }
            .padding(.horizontal, 20)
            .onAppear { store.send(.onAppear) }
            .animation(.easeInOut, value: store.status)
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

// MARK: - Subviews
private extension CheckAccountView {
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .frame(width: 120, height: 120)
                .tint(.gray100)

            TypographyText(
                text: "두런두런에 가입한 이력이 있는지\n확인하고 있어요.",
                style: .t2_700
            )
        }
    }
    
    private var loadedView: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                TypographyText( text: "이 본인인증 정보로 가입한\n계정이 있어요.", style: .h2_700, alignment: .left)
                TypographyText(text: "이 계정으로 로그인할까요?", style: .b1_400, color: .gray700, alignment: .left)
            }
            .padding(.top, 16)

            if let info = store.accountInfo {
                HStack(alignment: .top, spacing: 12) {
                    // 이미지
                    if let profileImage = info.profileImage {
                        Image(profileImage)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Color.gray100
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }

                    // 이름, 휴대폰 번호
                    VStack(alignment: .leading, spacing: 2) {
                        TypographyText(text: info.name, style: .t2_700)
                        TypographyText(text: info.phoneNumber, style: .b2_400)
                    }

                    Spacer()

                    // 가입 날짜
                    TypographyText(text: info.joinDate, style: .c1_400, color: .gray500)
                }
                .padding(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray100, lineWidth: 1)
                )
            }

            Spacer()

            AppButton(title: "로그인 하기") { store.send(.loginButtonTapped) }
            .padding(.bottom, 24)
        }
    }

    private var failedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Rectangle()
                .frame(width: 120, height: 120)
                .tint(.gray100)

            TypographyText(
                text: "두런두런에 가입한 이력이 없어요",
                style: .t2_700
            )
            
            Spacer()
            
            AppButton(title: "회원가입 하기") { store.send(.signupButtonTapped) }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Preview
#Preview {
    CheckAccountView(
        store: Store(initialState: CheckAccountFeature.State()) {
            CheckAccountFeature()
        }
    )
}
