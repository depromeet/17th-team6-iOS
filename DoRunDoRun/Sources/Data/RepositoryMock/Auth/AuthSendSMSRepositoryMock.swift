//
//  AuthSendSMSRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import Foundation

final class AuthSendSMSRepositoryMock: AuthSendSMSRepository {
    func sendSMS(phoneNumber: String) async throws {
        print("[Mock] 인증번호 전송 성공: \(phoneNumber)")
    }
}
