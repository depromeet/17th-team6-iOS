//
//  SelfieFeedViewState.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/6/25.
//

import Foundation

struct SelfieFeedViewState: Identifiable, Equatable {
    enum Kind: Equatable {
        case monthHeader(year: String, month: String)
        case certification(SelfieFeedItem)
    }

    let id: String
    let kind: Kind
}

struct SelfieFeedItem: Equatable {
    let feedID: Int
    let dayText: String
    let imageURL: String?
    let isMap: Bool
}

