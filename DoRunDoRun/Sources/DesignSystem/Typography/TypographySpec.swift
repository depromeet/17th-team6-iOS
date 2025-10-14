import SwiftUI

/// 개별 타이포그래피 스타일의 속성을 정의하는 구조체
struct TypographySpec: Equatable {
    public let size: CGFloat
    public let lineHeight: CGFloat
    public let letterSpacing: CGFloat
    public let weight: PretendardWeight
    public let textStyle: Font.TextStyle

    public init(
        size: CGFloat,
        lineHeight: CGFloat,
        letterSpacing: CGFloat,
        weight: PretendardWeight,
        textStyle: Font.TextStyle
    ) {
        self.size = size
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.weight = weight
        self.textStyle = textStyle
    }
}
