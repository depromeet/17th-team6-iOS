import SwiftUI

// MARK: - 버튼 스타일
enum AppButtonStyle {
    case primary
    case secondary
    case destructive
    case disabled
    case cancel
    case text
}

// MARK: - 버튼 사이즈
enum AppButtonSize {
    case fullWidth
    case medium
    case small
    
    var height: CGFloat {
        switch self {
        case .fullWidth: return 56
        case .medium: return 44
        case .small: return 32
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .fullWidth: return 12
        case .medium: return 10
        case .small: return 6
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .fullWidth: return 0
        case .medium: return 16
        case .small: return 10
        }
    }
    
    var typographyStyle: TypographyStyle {
        switch self {
        case .fullWidth, .medium:
            return .b1_700
        case .small:
            return .c1_700
        }
    }
}

// MARK: - AppButton
struct AppButton: View {
    let title: String
    let style: AppButtonStyle
    let size: AppButtonSize
    let icon: Image?
    let underlineTarget: String?
    let action: () -> Void
    
    // MARK: - 초기화
    init(
        title: String,
        style: AppButtonStyle = .primary,
        size: AppButtonSize = .fullWidth,
        isDisabled: Bool = false,
        underlineTarget: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.icon = nil
        self.underlineTarget = underlineTarget
        self.action = action
    }
    
    init(
        title: String,
        style: AppButtonStyle,
        size: AppButtonSize,
        icon: Image,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        precondition(
            size == .medium && (style == .secondary || style == .disabled),
            "❌ 아이콘은 Medium 사이즈의 Secondary 또는 Disabled 스타일에서만 사용할 수 있습니다."
        )
        self.title = title
        self.style = style
        self.size = size
        self.icon = icon
        self.underlineTarget = nil
        self.action = action
    }
    
    private var buttonHeight: CGFloat {
        style == .text ? 29 : size.height
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            content
                .frame(maxWidth: size == .fullWidth ? .infinity : nil)
                .frame(height: buttonHeight)
                .background(backgroundColor)
                .cornerRadius(size.cornerRadius)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 콘텐츠
    @ViewBuilder
    private var content: some View {
        switch style {
        case .text:
            if let target = underlineTarget {
                TypographyUnderlineText(text: title, target: target, style: .b2_500, color: textColor)
            } else {
                TypographyText(text: title, style: .b2_500, color: textColor)
            }
        default:
            HStack(spacing: 4) {
                TypographyText(text: title, style: size.typographyStyle, color: textColor)
                if let icon = icon {
                    icon
                        .renderingMode(.template)
                        .foregroundStyle(textColor)
                }
            }
            .padding(.horizontal, size.horizontalPadding)
        }
    }
    
    // MARK: - 색상
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .blue600
        case .secondary:
            switch size {
            case .fullWidth:
                return .gray900
            case .medium, .small:
                return .blue200
            }
        case .destructive:
            return .redLight
        case .disabled:
            return .gray100
        case .cancel:
            return .gray100
        case .text:
            return .gray0
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .gray0
        case .secondary:
            switch size {
            case .fullWidth:
                return .gray0
            case .medium, .small:
                return .blue600
            }
        case .destructive:
            return .red
        case .disabled:
            return .gray400
        case .cancel:
            return .gray900
        case .text:
            return .gray500
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        Group {
            AppButton(title: "확인", style: .primary) {}
            AppButton(title: "취소", style: .cancel) {}
            AppButton(title: "삭제하기", style: .destructive) {}
            AppButton(title: "비활성화", style: .disabled, isDisabled: true) {}
        }
        
        Divider()
        
        Group {
            AppButton(title: "텍스트 버튼", style: .text) {}
            AppButton(title: "밑줄 있는 텍스트 버튼", style: .text, underlineTarget: "밑줄") {}
        }
        
        Divider()
        
        Group {
            AppButton(title: "Medium + 아이콘", style: .secondary, size: .medium, icon: Image(.react, fill: .fill, size: .small)) {}
            AppButton(title: "Medium Disabled + 아이콘", style: .disabled, size: .medium, icon: Image(.react, fill: .fill, size: .small)) {}
        }
    }
    .padding()
    .background(Color.gray0)
}
