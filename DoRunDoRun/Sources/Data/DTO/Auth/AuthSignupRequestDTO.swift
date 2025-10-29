//
//  AuthSignupRequestDTO.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

struct AuthSignupRequestDTO: Encodable {
    let phoneNumber: String
    let nickname: String
    let consent: ConsentDTO
    let deviceToken: String
}

struct ConsentDTO: Encodable {
    let marketingConsentAt: String?
    let locationConsentAt: String
    let personalConsentAt: String
}
