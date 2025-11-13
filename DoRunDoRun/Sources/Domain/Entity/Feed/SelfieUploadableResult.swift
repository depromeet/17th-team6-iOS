//
//  SelfieUploadableResult.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/13/25.
//

import Foundation

struct SelfieUploadableResult: Equatable {
    let isUploadable: Bool
    let reason: UploadableReason
}

enum UploadableReason: String, Equatable {
    case runNotToday = "RUN_NOT_TODAY"
    case alreadyUploadedToday = "ALREADY_UPLOADED_TODAY"
    case continueUpload = "CONTINUE"
    case unknown
}
