import SwiftUI

// MARK: - 버튼 스타일 타입
enum ButtonStyleType {
    case primary      // 파란 버튼
    case secondary    // 회색 버튼
    case destructive  // 빨간 버튼
    case text         // 텍스트 버튼
}

// MARK: - 버튼 사이즈
enum ButtonSize {
    case large
    case medium
    case small
    
    var height: CGFloat {
        switch self {
        case .large, .medium: return 56
        case .small: return 44
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .large, .medium: return 12
        case .small: return 8
        }
    }
}

// MARK: - 버튼 컴포넌트
struct AppButton: View {
    let title: String
    var style: ButtonStyleType = .primary
    var size: ButtonSize = .large
    var isDisabled: Bool = false
    var underlineTarget: String? = nil
    var action: () -> Void
    
    private var buttonHeight: CGFloat {
        style == .text ? 29 : size.height
    }
    
    var body: some View {
        Button(action: action) {
            if style == .text {
                if let target = underlineTarget {
                    // 특정 단어에만 밑줄
                    TypographyUnderlineText(
                        text: title,
                        target: target,
                        style: .b2_500,
                        color: textColor
                    )
                    .frame(maxWidth: .infinity, minHeight: buttonHeight)
                    .background(backgroundColor)
                } else {
                    // 그냥 텍스트만
                    TypographyText(text: title, style: .b2_500, color: textColor)
                        .frame(maxWidth: .infinity, minHeight: buttonHeight)
                        .background(backgroundColor)
                }
            } else {
                TypographyText(text: title, style: .b1_700, color: textColor)
                    .frame(maxWidth: .infinity, minHeight: buttonHeight)
                    .background(backgroundColor)
                    .cornerRadius(size.cornerRadius)
            }
        }
        .allowsHitTesting(!isDisabled)
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return style == .text ? .clear : .gray50
        }
        switch style {
        case .primary: return .blue600
        case .secondary: return .gray100
        case .destructive: return .redLight
        case .text: return .gray0
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            return .gray400
        }
        switch style {
        case .primary: return .gray0
        case .secondary: return .gray700
        case .destructive: return .red
        case .text: return .gray500
        }
    }
}

// MARK: - 프리뷰
#Preview {
    VStack(spacing: 16) {
        // Filled buttons
        AppButton(title: "확인", style: .primary) {}
        AppButton(title: "취소", style: .secondary) {}
        AppButton(title: "삭제하기", style: .destructive) {}

        Divider()

        // Disabled
        AppButton(title: "확인", style: .primary, isDisabled: true) {}
        AppButton(title: "취소", style: .secondary, isDisabled: true) {}
        AppButton(title: "삭제하기", style: .destructive, isDisabled: true) {}

        Divider()

        // Text-only buttons
        AppButton(title: "텍스트 버튼", style: .text) {}

        Divider()

        // Size variations
        AppButton(title: "Large", size: .large) {}
        AppButton(title: "Medium", size: .medium) {}
            .frame(width: 140)
        AppButton(title: "Small", size: .small) {}
            .frame(width: 75)
    }
    .padding(.horizontal, 20)
}
