import SwiftUI

/// 앱의 **디자인 시스템 컬러 토큰(Color Tokens)** 을 정의하는 확장입니다.
///
/// `Color(hex:)` 초기화를 통해 HEX 기반 색상을 정의하며,
/// 일관된 색상 시스템을 유지하기 위해 앱 전역에서 이 컬러만 사용합니다.
///
/// **사용 예시**
///
/// ```swift
/// // 텍스트 색상 지정
/// Text("시작하기")
///     .foregroundStyle(.blue600)
///
/// // 배경색 지정
/// Rectangle()
///     .fill(Color.gray50)
///
/// // 상태 색상 사용
/// Label("실패", systemImage: "xmark.circle")
///     .foregroundStyle(.red)
/// ```
///
/// **컬러 그룹**
/// - Primary: 브랜드 메인 블루 계열 (`.blue900` ~ `.blue100`)
/// - Secondary: 서브 포인트 컬러 (`.lime600`)
/// - Grayscale: 텍스트/배경 기본 톤 (`.gray900` ~ `.gray0`)
/// - Semantic: 상태 표현용 (`.red`, `.yellow`, `.green`)
///
/// > 💡 **Note**
/// > - `Color(hex:)` 생성자를 통해 HEX 코드로 직접 정의할 수 있습니다.
/// > - 새로운 컬러를 추가할 때는 디자인 시스템 팀과 협의해야 합니다.

extension Color {
    // MARK: - Primary
    static let blue900 = Color(hex: 0x1A2066)
    static let blue800 = Color(hex: 0x252FA0)
    static let blue700 = Color(hex: 0x2F3FCC)
    static let blue600 = Color(hex: 0x3E4FFF)
    static let blue500 = Color(hex: 0x4C74FF)
    static let blue400 = Color(hex: 0x6A91FF)
    static let blue300 = Color(hex: 0x9AB4FF)
    static let blue200 = Color(hex: 0xC6D3FF)
    static let blue100 = Color(hex: 0xEDF2FF)

    // MARK: - Secondary
    static let lime600 = Color(hex: 0xD2FF3E)

    // MARK: - Grayscale
    static let gray900 = Color(hex: 0x232529)
    static let gray800 = Color(hex: 0x3B3E43)
    static let gray700 = Color(hex: 0x494D54)
    static let gray600 = Color(hex: 0x585D64)
    static let gray500 = Color(hex: 0x747A83)
    static let gray400 = Color(hex: 0x8F949C)
    static let gray300 = Color(hex: 0xB5B9C0)
    static let gray200 = Color(hex: 0xC9CED4)
    static let gray100 = Color(hex: 0xD7DBE3)
    static let gray50  = Color(hex: 0xF0F3F8)
    static let gray10  = Color(hex: 0xF9FAFB)
    static let gray0   = Color(hex: 0xFFFFFF) // White

    // MARK: - Semantic
    static let red = Color(hex: 0xFF443B)
    static let redLight = Color(hex: 0xFFE5E4)
    static let yellow = Color(hex: 0xFFE14D)
    static let green = Color(hex: 0x2DDD93)
    
    // MARK: - Dim
    static let dimLight = Color(hex: 0x000000, alpha: 0.4)
    static let dimDark  = Color(hex: 0x000000, alpha: 0.6)
}
