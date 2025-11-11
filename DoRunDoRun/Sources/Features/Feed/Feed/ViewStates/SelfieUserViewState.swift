//
//  SelfieUserViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import Foundation

struct SelfieUserViewState: Equatable, Identifiable {
    let id: Int
    let name: String
    let profileImageUrl: String
    let postingTime: String
    let isMe: Bool
}
