//
//  AuthSendSMSRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

protocol AuthSendSMSRepository {
    func sendSMS(phoneNumber: String) async throws
}
