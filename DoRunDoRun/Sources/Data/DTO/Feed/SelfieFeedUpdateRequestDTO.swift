//
//  SelfieFeedUpdateRequestDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/10/25.
//

import Foundation

/// 인증피드 수정 요청 DTO (UpdateSelfieRequest)
struct SelfieFeedUpdateRequestDTO: Encodable {
    /// 피드 내용
    let content: String
    /// 셀피 이미지 삭제 여부
    let deleteSelfieImage: Bool
    
    init(content: String, deleteSelfieImage: Bool = false) {
        self.content = content
        self.deleteSelfieImage = deleteSelfieImage
    }
}
