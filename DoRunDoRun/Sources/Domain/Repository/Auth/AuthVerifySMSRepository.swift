//
//  AuthVerifySMSRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

protocol AuthVerifySMSRepository {
    func verifySMS(phoneNumber: String, verificationCode: String) async throws -> PhoneVerificationResult
}
