//
//  EditProfileView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/7/25.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct EditProfileView: View {
    @Perception.Bindable var store: StoreOf<EditProfileFeature>
    @FocusState private var focusedField: Field?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                profileImageSection
                nicknameSection
                Spacer()
                toastAndButtonSection
            }
            .padding(.horizontal, 20)
            .task {
                focusedField = .nickname
            }
            .navigationTitle("프로필 수정")
            .navigationBarTitleDisplayMode(.inline)
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

// MARK: - ProfileImage
extension EditProfileView {
    private var profileImageSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                if let image = store.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 97, height: 97)
                        .clipShape(Circle())
                } else {
                    Image(.profilePlaceholder)
                        .frame(width: 97, height: 97)
                        .clipShape(Circle())
                }

                Image(.camera, fill: .fill, size: .small)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray0)
                    .frame(width: 30, height: 30)
                    .background(
                        ZStack {
                            Circle().fill(Color.gray500)
                            Circle().strokeBorder(Color.gray0, lineWidth: 1)
                        }
                    )
                    .offset(x: 33.5, y: 33.5)
            }
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    store.send(.imagePicked(image))
                }
            }
        }
    }
}

// MARK: - Nickname
extension EditProfileView {
    private var nicknameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InputField(placeholder: "닉네임 입력", text: $store.nickname)
                .focused($focusedField, equals: .nickname)
            HStack(spacing: 4) {
                Image(.check, size: .small)
                    .renderingMode(.template)
                    .foregroundStyle(store.isNicknameValid ? Color.blue600 : Color.gray400)
                TypographyText(
                    text: "닉네임 2-8자",
                    style: .c1_500,
                    color: store.isNicknameValid ? .blue600 : .gray400,
                    alignment: .left
                )
            }
            .animation(.easeInOut(duration: 0.2), value: store.nickname)
        }
        .padding(.top, 32)
    }
}

// MARK: - ToastAndButton
extension EditProfileView {
    private var toastAndButtonSection: some View {
        VStack(spacing: 0) {
            if store.toast.isVisible {
                ActionToastView(message: store.toast.message)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.3), value: store.toast.isVisible)
            }
            
            AppButton(
                title: "완료",
                style: store.isNicknameValid ? .primary : .disabled
            ) {
                store.send(.bottomButtonTapped)
            }
            .padding(.bottom, focusedField == nil ? 24 : 12)
            .animation(.easeInOut(duration: 0.25), value: focusedField)
        }
    }
}

// MARK: - Preview
#Preview {
    EditProfileView(
        store: Store(
            initialState: EditProfileFeature.State(
                profileImage: nil, nickname: "두런두런"
            ),
            reducer: { EditProfileFeature() }
        )
    )
}
