//
//  OnboardingPermissionPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingPermissionPresentationLogic {
    func presentAgreements(response: OnboardingPermission.LoadAgreements.Response)
    func presentToggleAll(response: OnboardingPermission.ToggleAll.Response)
    func presentToggleOne(response: OnboardingPermission.ToggleOne.Response)
}

final class OnboardingPermissionPresenter {
    weak var viewController: OnboardingPermissionDisplayLogic?
}

extension OnboardingPermissionPresenter: OnboardingPermissionPresentationLogic {
    func presentAgreements(response: OnboardingPermission.LoadAgreements.Response) {
        let displayed = response.agreements.map {
            DisplayedAgreement(title: $0.title, isChecked: $0.isChecked)
        }
        viewController?.displayAgreements(viewModel: .init(displayedAgreements: displayed))
    }
    
    func presentToggleAll(response: OnboardingPermission.ToggleAll.Response) {
        let displayed = response.agreements.map {
            DisplayedAgreement(title: $0.title, isChecked: $0.isChecked)
        }
        let isAllChecked = response.agreements.allSatisfy { $0.isChecked }
        let isNextEnabled = response.agreements.filter { $0.isRequired }.allSatisfy { $0.isChecked }
        
        let viewModel = OnboardingPermission.ToggleAll.ViewModel(
            displayedAgreements: displayed,
            isAllChecked: isAllChecked,
            isNextEnabled: isNextEnabled
        )
        viewController?.displayToggleAll(viewModel: viewModel)
    }
    
    func presentToggleOne(response: OnboardingPermission.ToggleOne.Response) {
        let agreement = response.agreements[response.index]
        let displayed = DisplayedAgreement(title: agreement.title, isChecked: agreement.isChecked)
        let isAllChecked = response.agreements.allSatisfy { $0.isChecked }
        let isNextEnabled = response.agreements.filter { $0.isRequired }.allSatisfy { $0.isChecked }
        
        let viewModel = OnboardingPermission.ToggleOne.ViewModel(
            displayedAgreement: displayed,
            index: response.index,
            isAllChecked: isAllChecked,
            isNextEnabled: isNextEnabled
        )
        viewController?.displayToggleOne(viewModel: viewModel)
    }
}
