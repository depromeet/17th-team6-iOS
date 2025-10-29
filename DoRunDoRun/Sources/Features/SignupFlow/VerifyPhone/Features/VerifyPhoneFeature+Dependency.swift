//
//  VerifyPhoneFeature+Dependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import ComposableArchitecture

extension DependencyValues {
    /// 인증번호 전송 UseCase
    var authSendSMSUseCase: AuthSendSMSUseCaseProtocol {
        get { self[AuthSendSMSUseCaseKey.self] }
        set { self[AuthSendSMSUseCaseKey.self] = newValue }
    }
    
    /// 인증번호 검증 UseCase
    var authVerifySMSUseCase: AuthVerifySMSUseCaseProtocol {
        get { self[AuthVerifySMSUseCaseKey.self] }
        set { self[AuthVerifySMSUseCaseKey.self] = newValue }
    }
}

// MARK: - Keys
private enum AuthSendSMSUseCaseKey: DependencyKey {
    static let liveValue: AuthSendSMSUseCaseProtocol = AuthSendSMSUseCase(
        repository: AuthSendSMSRepositoryMock()
    )
    static let testValue: AuthSendSMSUseCaseProtocol = AuthSendSMSUseCase(
        repository: AuthSendSMSRepositoryMock()
    )
}

private enum AuthVerifySMSUseCaseKey: DependencyKey {
    static let liveValue: AuthVerifySMSUseCaseProtocol = AuthVerifySMSUseCase(
        repository: AuthVerifySMSRepositoryMock()
    )
    static let testValue: AuthVerifySMSUseCaseProtocol = AuthVerifySMSUseCase(
        repository: AuthVerifySMSRepositoryMock()
    )
}
