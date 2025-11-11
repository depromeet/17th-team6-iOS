//
//  UserLocationViewStateMapper.swift
//  DoRunDoRun
//
//  Created by zaehorang on 11/10/25.
//

enum UserLocationViewStateMapper {
    static func map(from coordinate: RunningCoordinate) -> UserLocationViewState {
        return UserLocationViewState(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}
