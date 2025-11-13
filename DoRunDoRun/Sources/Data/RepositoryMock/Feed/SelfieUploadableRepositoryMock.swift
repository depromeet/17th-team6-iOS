//
//  SelfieUploadableRepositoryMock.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

final class SelfieUploadableRepositoryMock: SelfieUploadableRepository {
    var stubResult: SelfieUploadableResult = .init(
        isUploadable: true,
        reason: .continueUpload
    )
    
    func checkUploadable(runSessionId: Int) async throws -> SelfieUploadableResult {
        print("[Mock] 업로드 가능 여부 확인 (runSessionId: \(runSessionId)) → \(stubResult)")
        return stubResult
    }
}
