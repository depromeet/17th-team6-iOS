import SwiftUI

/// 개별 타이포그래피 스타일의 속성을 정의하는 구조체
struct TypographySpec: Equatable {
    let size: CGFloat
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    let weight: PretendardWeight
    let textStyle: Font.TextStyle

    init(
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
