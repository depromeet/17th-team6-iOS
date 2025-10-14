import SwiftUI

/// 앱의 **타이포그래피 시스템**을 적용하는 `ViewModifier` 및 헬퍼 메서드입니다.
///
/// `AppTextStyle`에 정의된 폰트 크기, 줄 높이, 자간, 폰트 두께를 자동으로 적용하며
/// Pretendard 폰트를 기반으로 한 일관된 텍스트 스타일을 제공합니다.
///
/// **사용 예시**
///
/// ```swift
/// VStack(alignment: .leading, spacing: 8) {
///     Text("오늘의 러닝")
///         .typography(.h2_700, color: .blue600)
///
///     Text("두런두런, 목표를 향해 달리는")
///         .typography(.b1_400, color: .gray700)
/// }
/// ```
///
/// **파라미터**
/// - `style`: 적용할 `AppTextStyle`
/// - `color`: 텍스트 색상 (기본값: `.primary`)
///
/// > 💡 **Note**
/// > - `.typography(_:, color:)`는 `TypographyModifier`를 간편하게 사용할 수 있는 뷰 확장입니다.
/// > - lineHeight와 폰트 크기 차이를 고려하여 상하 패딩이 자동 조정됩니다.


/// AppTextStyle을 적용하는 ViewModifier
struct TypographyModifier: ViewModifier {
    private let style: AppTextStyle
    private let color: Color?

    public init(_ style: AppTextStyle, color: Color? = nil) {
        self.style = style
        self.color = color
    }

    public func body(content: Content) -> some View {
        let spec = style.spec
        let topBottomInset = max((spec.lineHeight - spec.size) / 2, 0)

        return content
            .font(.pretendard(spec.weight, size: spec.size, relativeTo: spec.textStyle))
            .kerning(spec.letterSpacing)
            .lineSpacing(max(spec.lineHeight - spec.size, 0))
            .padding(.vertical, topBottomInset)
            .foregroundStyle(color ?? .primary)
    }
}

extension View {
    /// Text("텍스트").typography(.b1_400, color: .gray900)
    func typography(_ style: AppTextStyle, color: Color? = nil) -> some View {
        modifier(TypographyModifier(style, color: color))
    }
}
