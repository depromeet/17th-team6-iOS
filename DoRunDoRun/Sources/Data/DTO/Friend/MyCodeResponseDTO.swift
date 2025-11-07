//
//  MyCodeResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/8/25.
//

struct MyCodeResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: MyCodeDataDTO

    struct MyCodeDataDTO: Decodable {
        let code: String
    }
}
