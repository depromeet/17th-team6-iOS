import SwiftUI

enum TypographyStyle: CaseIterable {
    case countdown_700
    case distance_700
    
    // MARK: - Headline
    case h1_700, h1_500
    case h2_700, h2_500, h2_400
    case h3_700, h4_700

    // MARK: - Title
    case t1_700, t1_500, t1_400
    case t2_700, t2_500, t2_400

    // MARK: - Body
    case b1_700, b1_500, b1_400
    case b2_700, b2_500, b2_400

    // MARK: - Caption
    case c1_700, c1_500, c1_400

    public var spec: TypographySpec {
        switch self {
        case .countdown_700:
            return .init(size: 96, lineHeight: 106, letterSpacing: -0.2, weight: .bold, textStyle: .largeTitle)
        case .distance_700:
            return .init(size: 68, lineHeight: 50, letterSpacing: -0.2, weight: .bold, textStyle: .largeTitle)
        // MARK: - Headline
        case .h1_700:
            return .init(size: 28, lineHeight: 38, letterSpacing: -0.2, weight: .bold, textStyle: .largeTitle)
        case .h1_500:
            return .init(size: 28, lineHeight: 38, letterSpacing: -0.2, weight: .medium, textStyle: .largeTitle)
        case .h2_700:
            return .init(size: 24, lineHeight: 34, letterSpacing: -0.2, weight: .bold, textStyle: .title)
        case .h2_500:
            return .init(size: 24, lineHeight: 34, letterSpacing: -0.2, weight: .medium, textStyle: .title)
        case .h2_400:
            return .init(size: 24, lineHeight: 34, letterSpacing: -0.2, weight: .regular, textStyle: .title)
        case .h3_700:
            return .init(size: 32, lineHeight: 42, letterSpacing: -0.2, weight: .bold, textStyle: .title)
        case .h4_700:
            return .init(size: 40, lineHeight: 50, letterSpacing: -0.2, weight: .bold, textStyle: .title)

        // MARK: - Title
        case .t1_700:
            return .init(size: 20, lineHeight: 28, letterSpacing: -0.2, weight: .bold, textStyle: .title2)
        case .t1_500:
            return .init(size: 20, lineHeight: 28, letterSpacing: -0.2, weight: .medium, textStyle: .title2)
        case .t1_400:
            return .init(size: 20, lineHeight: 28, letterSpacing: -0.2, weight: .regular, textStyle: .title2)
        case .t2_700:
            return .init(size: 18, lineHeight: 26, letterSpacing: -0.2, weight: .bold, textStyle: .title3)
        case .t2_500:
            return .init(size: 18, lineHeight: 26, letterSpacing: -0.2, weight: .medium, textStyle: .title3)
        case .t2_400:
            return .init(size: 18, lineHeight: 26, letterSpacing: -0.2, weight: .regular, textStyle: .title3)

        // MARK: - Body
        case .b1_700:
            return .init(size: 16, lineHeight: 24, letterSpacing: -0.2, weight: .bold, textStyle: .body)
        case .b1_500:
            return .init(size: 16, lineHeight: 24, letterSpacing: -0.2, weight: .medium, textStyle: .body)
        case .b1_400:
            return .init(size: 16, lineHeight: 24, letterSpacing: -0.2, weight: .regular, textStyle: .body)
        case .b2_700:
            return .init(size: 14, lineHeight: 21, letterSpacing: -0.2, weight: .bold, textStyle: .callout)
        case .b2_500:
            return .init(size: 14, lineHeight: 21, letterSpacing: -0.2, weight: .medium, textStyle: .callout)
        case .b2_400:
            return .init(size: 14, lineHeight: 21, letterSpacing: -0.2, weight: .regular, textStyle: .callout)

        // MARK: - Caption
        case .c1_700:
            return .init(size: 12, lineHeight: 18, letterSpacing: -0.2, weight: .bold, textStyle: .caption)
        case .c1_500:
            return .init(size: 12, lineHeight: 18, letterSpacing: -0.2, weight: .medium, textStyle: .caption)
        case .c1_400:
            return .init(size: 12, lineHeight: 18, letterSpacing: -0.2, weight: .regular, textStyle: .caption)
        }
    }
}
