//
//  SelfieUserViewStateMapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation

enum SelfieUserViewStateMapper {
    /// 단일 변환 (도메인 → 뷰)
    static func map(from user: SelfieUserResult) -> SelfieUserViewState {
        let relativeTime = DateFormatterManager.shared.formatRelativeTime(from: user.postingTime)

        return SelfieUserViewState(
            id: user.id,
            name: user.name,
            profileImageUrl: user.profileImageUrl,
            postingTime: relativeTime,
            isMe: user.isMe
        )
    }

    /// 리스트 변환 (도메인 리스트 → 뷰 리스트)
    static func mapList(from users: [SelfieUserResult]) -> [SelfieUserViewState] {
        users.map { map(from: $0) }
    }
}
