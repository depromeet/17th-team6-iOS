//
//  SelfieFeedCreateRequestDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/12/25.
//

struct SelfieFeedCreateRequestDTO: Encodable {
    let runningSessionId: Int
    let content: String
}
