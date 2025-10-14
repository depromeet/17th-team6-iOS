import SwiftUI

extension Font {
    /// Pretendard 폰트를 쉽게 불러오는 헬퍼
    static func pretendard(
        _ weight: PretendardWeight,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle? = nil
    ) -> Font {
        if let textStyle {
            return .custom(weight.rawValue, size: size, relativeTo: textStyle)
        } else {
            return .custom(weight.rawValue, size: size)
        }
    }
}
