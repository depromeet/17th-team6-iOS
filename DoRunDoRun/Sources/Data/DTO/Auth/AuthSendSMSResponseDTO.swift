//
//  AuthSendSMSResponseDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/27/25.
//

struct AuthSendSMSResponseDTO: Decodable {
    let status: String
    let message: String
    let timestamp: String
    let data: [String: String]?
}
