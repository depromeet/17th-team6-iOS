//
//  SelfieUploadableRepositoryImpl.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

final class SelfieUploadableRepositoryImpl: SelfieUploadableRepository {
    private let service: SelfieFeedService
    
    init(service: SelfieFeedService = SelfieFeedServiceImpl()) {
        self.service = service
    }
    
    func checkUploadable(runSessionId: Int) async throws -> SelfieUploadableResult {
        let dto = try await service.checkUploadable(runSessionId: runSessionId)
        return dto.toDomain()
    }
}
