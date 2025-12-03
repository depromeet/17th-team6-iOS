//
//  AuthDependency.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 12/2/25.
//

import Dependencies

extension DependencyValues {
    // MARK: - 인증번호 전송
    var authSendSMSUseCase: AuthSendSMSUseCaseProtocol {
        get { self[AuthSendSMSUseCaseKey.self] }
        set { self[AuthSendSMSUseCaseKey.self] = newValue }
    }
    
    // MARK: - 인증번호 검증
    var authVerifySMSUseCase: AuthVerifySMSUseCaseProtocol {
        get { self[AuthVerifySMSUseCaseKey.self] }
        set { self[AuthVerifySMSUseCaseKey.self] = newValue }
    }
    
    // MARK: - 회원가입
    var authSignupUseCase: AuthSignupUseCaseProtocol {
        get { self[AuthSignupUseCaseKey.self] }
        set { self[AuthSignupUseCaseKey.self] = newValue }
    }
    
    // MARK: - 로그아웃
    var authLogoutUseCase: AuthLogoutUseCaseProtocol {
        get { self[AuthLogoutUseCaseKey.self] }
        set { self[AuthLogoutUseCaseKey.self] = newValue }
    }

    // MARK: - 탈퇴
    var authWithdrawUseCase: AuthWithdrawUseCaseProtocol {
        get { self[AuthWithdrawUseCaseKey.self] }
        set { self[AuthWithdrawUseCaseKey.self] = newValue }
    }
}

// MARK: - Key

/// 인증번호 전송
private enum AuthSendSMSUseCaseKey: DependencyKey {
    static let liveValue: AuthSendSMSUseCaseProtocol = AuthSendSMSUseCase(
        repository: AuthSendSMSRepositoryImpl()
    )
    static let testValue: AuthSendSMSUseCaseProtocol = AuthSendSMSUseCase(
        repository: AuthSendSMSRepositoryMock()
    )
}

/// 인증번호 검증
private enum AuthVerifySMSUseCaseKey: DependencyKey {
    static let liveValue: AuthVerifySMSUseCaseProtocol = AuthVerifySMSUseCase(
        repository: AuthVerifySMSRepositoryImpl()
    )
    static let testValue: AuthVerifySMSUseCaseProtocol = AuthVerifySMSUseCase(
        repository: AuthVerifySMSRepositoryMock()
    )
}

/// 회원가입
private enum AuthSignupUseCaseKey: DependencyKey {
    static let liveValue: AuthSignupUseCaseProtocol = AuthSignupUseCase(
        repository: AuthSignupRepositoryImpl()
    )
    static let testValue: AuthSignupUseCaseProtocol = AuthSignupUseCase(
        repository: AuthSignupRepositoryMock()
    )
}

/// 로그아웃
private enum AuthLogoutUseCaseKey: DependencyKey {
    static let liveValue: AuthLogoutUseCaseProtocol = AuthLogoutUseCase(
        repository: AuthLogoutRepositoryImpl()
    )
    static let testValue: AuthLogoutUseCaseProtocol = AuthLogoutUseCase(
        repository: AuthLogoutRepositoryMock()
    )
}

/// 탈퇴
private enum AuthWithdrawUseCaseKey: DependencyKey {
    static let liveValue: AuthWithdrawUseCaseProtocol = AuthWithdrawUseCase(
        repository: AuthWithdrawRepositoryImpl()
    )
    static let testValue: AuthWithdrawUseCaseProtocol = AuthWithdrawUseCase(
        repository: AuthWithdrawRepositoryMock()
    )
}
