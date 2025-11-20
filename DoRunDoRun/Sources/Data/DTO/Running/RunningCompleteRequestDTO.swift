//
//  RunningCompleteRequestDTO.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/4/25.
//

import Foundation

struct RunningCompleteRequestDTO: Encodable {
    let distance: DistanceDTO
    let duration: DurationDTO
    let pace: PaceDTO
    let cadence: CadenceDTO
}

struct DistanceDTO: Encodable {
    let total: Int  // 미터
}

struct DurationDTO: Encodable {
    let total: Int  // 초
}

struct PaceDTO: Encodable {
    let avg: Int  // 초/킬로미터
    let max: MaxPaceDTO
}

struct MaxPaceDTO: Encodable {
    let value: Int  // 초/킬로미터
    let latitude: Double
    let longitude: Double
}

struct CadenceDTO: Encodable {
    let avg: Int  // steps per minute
    let max: MaxCadenceDTO
}

struct MaxCadenceDTO: Encodable {
    let value: Int  // steps per minute
}

// MARK: - Domain to DTO Mapping
extension RunningCompleteRequestDTO {
    init(from request: RunningCompleteRequest) {
        self.distance = DistanceDTO(total: Int(request.totalDistanceMeters))

        // Duration을 초 단위로 변환
        let totalSeconds = request.elapsed.components.seconds + (request.elapsed.components.attoseconds / 1_000_000_000_000_000_000)
        self.duration = DurationDTO(total: Int(totalSeconds))

        self.pace = PaceDTO(
            avg: Int(request.avgPaceSecPerKm),
            max: MaxPaceDTO(
                value: Int(request.fastestPaceSecPerKm),
                latitude: request.coordinateAtMaxPace.latitude,
                longitude: request.coordinateAtMaxPace.longitude
            )
        )

        self.cadence = CadenceDTO(
            avg: Int(request.avgCadenceSpm),
            max: MaxCadenceDTO(value: Int(request.maxCadenceSpm))
        )
    }
}
