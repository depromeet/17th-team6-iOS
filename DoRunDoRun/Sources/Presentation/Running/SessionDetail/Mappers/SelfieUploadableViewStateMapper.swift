//
//  SelfieUploadableViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation

struct SelfieUploadableViewStateMapper {
    static func map(from entity: SelfieUploadableResult) -> SelfieUploadableViewState {
        return SelfieUploadableViewState(
            isUploadable: entity.isUploadable,
            reason: entity.reason
        )
    }
}
