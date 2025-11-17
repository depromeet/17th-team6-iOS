//
//  RunningConverterManager.swift
//  
//
//  Created by zaehorang on 11/17/25.
//


/// 러닝 관련 값 변환(단위/물리량) 전담 컨버터
enum RunningConverterManager {
    /// m/s → sec/km
    static func speedToPace(_ speed: Double) -> Double? {
        guard speed > 0 else { return nil }
        return 1000 / speed
    }
}