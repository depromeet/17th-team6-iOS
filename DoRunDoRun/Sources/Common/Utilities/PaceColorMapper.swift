import UIKit

/// 페이스 값(분/km)을 색상으로 매핑하는 유틸리티
struct PaceColorMapper {
    // MARK: - 페이스 구간 정의 (분/km)

    /// 매우 빠름: pace < 5:00
    private static let veryFastThreshold: Double = 300.0 // 5분 = 300초

    /// 빠름: 5:00 ≤ pace < 6:00
    private static let fastThreshold: Double = 360.0 // 6분 = 360초

    /// 보통: 6:00 ≤ pace < 7:00
    private static let moderateThreshold: Double = 420.0 // 7분 = 420초

    /// 느림: 7:00 ≤ pace < 8:00
    private static let slowThreshold: Double = 480.0 // 8분 = 480초

    // MARK: - 색상 정의 (요구사항 문서 기준)

    /// 매우 빠름 - 파랑 #4751FF
    private static let veryFastColor = UIColor(red: 0x47/255.0, green: 0x51/255.0, blue: 0xFF/255.0, alpha: 1.0)

    /// 빠름 - 연녹 #26FF00
    private static let fastColor = UIColor(red: 0x26/255.0, green: 0xFF/255.0, blue: 0x00/255.0, alpha: 1.0)

    /// 보통 - 노랑 #FFD700
    private static let moderateColor = UIColor(red: 0xFF/255.0, green: 0xD7/255.0, blue: 0x00/255.0, alpha: 1.0)

    /// 느림 - 주황 #FF8000
    private static let slowColor = UIColor(red: 0xFF/255.0, green: 0x80/255.0, blue: 0x00/255.0, alpha: 1.0)

    /// 매우 느림 - 빨강 #FF0000
    private static let verySlowColor = UIColor(red: 0xFF/255.0, green: 0x00/255.0, blue: 0x00/255.0, alpha: 1.0)

    // MARK: - Public Methods

    /// 페이스(초/km)를 기반으로 색상을 반환합니다.
    /// - Parameter paceSecPerKm: 페이스 값 (초/km)
    /// - Returns: 페이스에 해당하는 UIColor
    static func color(forPaceSecPerKm paceSecPerKm: Double) -> UIColor {
        // 0이거나 비정상적인 값은 기본 색상(회색) 반환
        guard paceSecPerKm > 0 else {
            return UIColor.gray
        }

        // 클램프: 5분보다 빠르면 파랑
        if paceSecPerKm < veryFastThreshold {
            return veryFastColor
        }

        // 클램프: 8분보다 느리면 빨강
        if paceSecPerKm >= slowThreshold {
            return verySlowColor
        }

        // 5-8분 범위에서 선형 보간
        return interpolateColor(paceSecPerKm: paceSecPerKm)
    }

    // MARK: - Private Methods

    /// 5-8분 범위에서 다중 스톱 선형 보간을 수행합니다.
    /// - Parameter paceSecPerKm: 페이스 값 (초/km)
    /// - Returns: 보간된 UIColor
    private static func interpolateColor(paceSecPerKm: Double) -> UIColor {
        // 각 구간별 보간

        // 구간 1: 5:00 ~ 6:00 (파랑 → 연녹)
        if paceSecPerKm < fastThreshold {
            let t = (paceSecPerKm - veryFastThreshold) / (fastThreshold - veryFastThreshold)
            return lerp(from: veryFastColor, to: fastColor, t: t)
        }

        // 구간 2: 6:00 ~ 7:00 (연녹 → 노랑)
        if paceSecPerKm < moderateThreshold {
            let t = (paceSecPerKm - fastThreshold) / (moderateThreshold - fastThreshold)
            return lerp(from: fastColor, to: moderateColor, t: t)
        }

        // 구간 3: 7:00 ~ 8:00 (노랑 → 주황 → 빨강)
        // 이 구간을 두 단계로 나눔
        let midPoint = (moderateThreshold + slowThreshold) / 2.0

        if paceSecPerKm < midPoint {
            // 7:00 ~ 7:30 (노랑 → 주황)
            let t = (paceSecPerKm - moderateThreshold) / (midPoint - moderateThreshold)
            return lerp(from: moderateColor, to: slowColor, t: t)
        } else {
            // 7:30 ~ 8:00 (주황 → 빨강)
            let t = (paceSecPerKm - midPoint) / (slowThreshold - midPoint)
            return lerp(from: slowColor, to: verySlowColor, t: t)
        }
    }

    /// 두 색상 사이를 선형 보간합니다.
    /// - Parameters:
    ///   - from: 시작 색상
    ///   - to: 끝 색상
    ///   - t: 보간 비율 (0.0 ~ 1.0)
    /// - Returns: 보간된 UIColor
    private static func lerp(from: UIColor, to: UIColor, t: Double) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        from.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let t = CGFloat(t)
        let r = r1 + (r2 - r1) * t
        let g = g1 + (g2 - g1) * t
        let b = b1 + (b2 - b1) * t
        let a = a1 + (a2 - a1) * t

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: - Convenience Extensions

extension PaceColorMapper {
    /// 분/km 형식의 페이스를 초/km로 변환하여 색상을 반환합니다.
    /// - Parameters:
    ///   - minutes: 분
    ///   - seconds: 초
    /// - Returns: 페이스에 해당하는 UIColor
    static func color(forMinutes minutes: Int, seconds: Int) -> UIColor {
        let totalSeconds = Double(minutes * 60 + seconds)
        return color(forPaceSecPerKm: totalSeconds)
    }
}
