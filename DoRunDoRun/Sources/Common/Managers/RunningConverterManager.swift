//
//  RunningConverterManager.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/17/25.
//

import Foundation

/// 러닝 도메인에서 사용되는 단위 변환 유틸리티
///
/// - View 포맷과는 분리된 순수 계산 로직을 담당합니다.
/// - UI 문자열 포맷은 RunningFormatterManager에서 처리합니다.
/// - Feature에서는 직접 계산하지 않고 이 Converter를 호출해야 합니다.
enum RunningConverterManager {
    
    // MARK: - Distance
    
    /// meters → kilometers
    ///
    /// 서버 또는 내부 계산 단위(m)를
    /// UI 표시용 km(Double)로 변환합니다.
    static func metersToKilometers(_ meters: Double) -> Double {
        meters / 1000
    }
    
    /// km.xx 입력값 → meters(Int)
    ///
    /// 예:
    /// 5km + 25(=0.25km) → 5250m
    ///
    /// 수기 입력 화면에서 받은 정수/소수 부분을
    /// 서버 요청용 meters 단위로 변환합니다.
    static func kmToMeters(whole: Int, decimal: Int) -> Int {
        whole * 1000 + decimal * 10
    }

    
    // MARK: - Duration
    
    /// seconds → (hour, minute, second)
    ///
    /// 서버 응답값(seconds)을
    /// 시간/분/초 구조로 분리할 때 사용합니다.
    static func secondsToHMS(_ seconds: Int) -> (h: Int, m: Int, s: Int) {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return (hours, minutes, secs)
    }
    
    /// DateComponents(h/m/s) → total seconds
    ///
    /// 예:
    /// 1시간 2분 30초 → 3750초
    ///
    /// 수기 입력 화면에서 받은 시간 컴포넌트를
    /// 서버 요청용 seconds로 변환합니다.
    static func hmsToSeconds(_ components: DateComponents) -> Int {
        (components.hour ?? 0) * 3600 +
        (components.minute ?? 0) * 60 +
        (components.second ?? 0)
    }

    
    // MARK: - Pace
    
    /// m/s → sec/km
    ///
    /// 평균 속도(m/s)를
    /// 1km당 걸린 시간(seconds)으로 변환합니다.
    ///
    /// speed가 0 이하인 경우 nil 반환
    static func speedToPace(_ speed: Double) -> Double? {
        guard speed > 0 else { return nil }
        return 1000 / speed
    }
    
    /// minute/second → total seconds
    ///
    /// 예:
    /// 4분 30초 → 270초
    ///
    /// 수기 입력 페이스를
    /// 내부 계산/서버 전송용 초 단위로 변환합니다.
    static func paceToSeconds(minute: Int, second: Int) -> Int {
        minute * 60 + second
    }

    
    // MARK: - Cadence
    
    /// spm(Double) → spm(Int)
    ///
    /// 서버 또는 계산 과정에서 Double로 존재하는 cadence를
    /// UI 및 내부 정수 단위로 변환합니다.
    static func cadenceToInt(_ spm: Double) -> Int {
        Int(spm)
    }
}
