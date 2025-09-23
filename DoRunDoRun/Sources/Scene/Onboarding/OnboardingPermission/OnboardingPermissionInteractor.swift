//
//  OnboardingPermissionInteractor.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingPermissionBusinessLogic {
    func loadAgreements(request: OnboardingPermission.LoadAgreements.Request)
    func toggleAll(request: OnboardingPermission.ToggleAll.Request)
    func toggleOne(request: OnboardingPermission.ToggleOne.Request)
}

protocol OnboardingPermissionDataStore {
    var agreements: [Agreement] { get set }
}

final class OnboardingPermissionInteractor: OnboardingPermissionDataStore {
    var presenter: OnboardingPermissionPresentationLogic?
    var agreements: [Agreement] = [
        Agreement(title: "[필수] 위치기반 정보 수집 동의", isRequired: true, isChecked: false),
        Agreement(title: "[필수] 개인정보 수집/이용 동의", isRequired: true, isChecked: false),
        Agreement(title: "[선택] 마케팅 정보 수신 동의", isRequired: false, isChecked: false)
    ]
}

extension OnboardingPermissionInteractor: OnboardingPermissionBusinessLogic {
    func loadAgreements(request: OnboardingPermission.LoadAgreements.Request) {
        presenter?.presentAgreements(response: .init(agreements: agreements))
    }
    
    func toggleAll(request: OnboardingPermission.ToggleAll.Request) {
        let isAllChecked = agreements.allSatisfy { $0.isChecked }
        agreements = agreements.map {
            Agreement(title: $0.title, isRequired: $0.isRequired, isChecked: !isAllChecked)
        }
        presenter?.presentToggleAll(response: .init(agreements: agreements))
    }
    
    func toggleOne(request: OnboardingPermission.ToggleOne.Request) {
        agreements[request.index].isChecked.toggle()
        presenter?.presentToggleOne(response: .init(agreements: agreements, index: request.index))
    }
}
