//
//  SelfieUploadableRepository.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

protocol SelfieUploadableRepository {
    func checkUploadable(runSessionId: Int) async throws -> SelfieUploadableResult
}
