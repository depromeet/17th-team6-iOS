import SwiftUI

import Kingfisher

/// 프로필 이미지 스타일
enum ProfileImageStyle {
    case plain          // 테두리 없음
    case grayBorder     // 회색 테두리
    case blueBorder     // 블루 테두리
}

/// 프로필 이미지 크기
enum ProfileImageSize {
    case small, medium, large
    
    var size: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 42
        case .large: return 52
        }
    }
    
    var cornerRadius: CGFloat { size / 2 }
}

struct ProfileImageView: View {
    let image: Image?
    let imageURL: String?
    let style: ProfileImageStyle
    let size: ProfileImageSize
    private let isZZZ: Bool
    
    // MARK: - Initializers
    /// 일반용 (small, medium, large 모두 가능)
    init(
        image: Image? = nil,
        imageURL: String? = nil,
        style: ProfileImageStyle = .plain,
        size: ProfileImageSize
    ) {
        self.image = image
        self.imageURL = imageURL
        self.style = style
        self.size = size
        self.isZZZ = false
    }
    
    /// large 전용 isZZZ 포함 initializer
    init(
        image: Image? = nil,
        imageURL: String? = nil,
        style: ProfileImageStyle = .plain,
        isZZZ: Bool
    ) {
        self.image = image
        self.imageURL = imageURL
        self.style = style
        self.size = .large
        self.isZZZ = isZZZ
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            profileBase
                .frame(width: size.size, height: size.size)
            
            if isZZZ {
                zzzOverlay
            }
        }
    }
    
    // MARK: - 내부 구성
    @ViewBuilder
    private var profileBase: some View {
        if let urlString = imageURL, let url = URL(string: urlString) {
            // 네트워크 이미지 우선
            KFImage(url)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(borderOverlay)
        } else if let image {
            // 로컬 이미지 사용
            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(borderOverlay)
        } else {
            Circle()
                .fill(Color.gray0)
                .overlay(borderOverlay)
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .plain:
            EmptyView()
        case .grayBorder:
            Circle().strokeBorder(Color.gray200, lineWidth: 1)
        case .blueBorder:
            Circle().strokeBorder(Color.blue500, lineWidth: 1)
        }
    }
    
    private var zzzOverlay: some View {
        TypographyText(text: "ZZZ", style: .c1_700, color: .gray0)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(Color.gray500)
            .cornerRadius(93)
            .offset(x: -8, y: -4)
    }
}

#Preview {
    VStack(spacing: 16) {
        // small — zzz 없음
        HStack {
            ProfileImageView(image: nil, style: .plain, size: .small)
            ProfileImageView(image: nil, style: .grayBorder, size: .small)
            ProfileImageView(image: nil, style: .blueBorder, size: .small)
        }
        
        // medium — zzz 없음
        HStack {
            ProfileImageView(image: nil, style: .plain, size: .medium)
            ProfileImageView(image: nil, style: .grayBorder, size: .medium)
            ProfileImageView(image: nil, style: .blueBorder, size: .medium)
        }
        
        // large 일반
        HStack {
            ProfileImageView(image: nil, style: .plain, size: .large)
            ProfileImageView(image: nil, style: .grayBorder, size: .large)
            ProfileImageView(image: nil, style: .blueBorder, size: .large)
        }
        
        // large + zzz (전용 init)
        HStack {
            ProfileImageView(image: nil, style: .plain, isZZZ: true)
            ProfileImageView(image: nil, style: .grayBorder, isZZZ: true)
            ProfileImageView(image: nil, style: .blueBorder, isZZZ: true)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.blue100)
}
