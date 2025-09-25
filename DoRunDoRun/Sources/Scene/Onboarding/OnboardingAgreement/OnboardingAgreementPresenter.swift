//
//  OnboardingAgreementPresenter.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/20/25.
//

import UIKit

protocol OnboardingAgreementPresentationLogic {
    func presentAgreements(response: OnboardingAgreement.LoadAgreements.Response)
    func presentToggleAll(response: OnboardingAgreement.ToggleAll.Response)
    func presentToggleOne(response: OnboardingAgreement.ToggleOne.Response)
}

final class OnboardingAgreementPresenter {
    weak var viewController: OnboardingAgreementDisplayLogic?
}

extension OnboardingAgreementPresenter: OnboardingAgreementPresentationLogic {
    func presentAgreements(response: OnboardingAgreement.LoadAgreements.Response) {
        let displayed = response.agreements.map {
            DisplayedAgreement(title: $0.title, isChecked: $0.isChecked)
        }
        viewController?.displayAgreements(viewModel: .init(displayedAgreements: displayed))
    }
    
    func presentToggleAll(response: OnboardingAgreement.ToggleAll.Response) {
        let displayed = response.agreements.map {
            DisplayedAgreement(title: $0.title, isChecked: $0.isChecked)
        }
        let isAllChecked = response.agreements.allSatisfy { $0.isChecked }
        let isNextEnabled = response.agreements.filter { $0.isRequired }.allSatisfy { $0.isChecked }
        
        let viewModel = OnboardingAgreement.ToggleAll.ViewModel(
            displayedAgreements: displayed,
            isAllChecked: isAllChecked,
            isNextEnabled: isNextEnabled
        )
        viewController?.displayToggleAll(viewModel: viewModel)
    }
    
    func presentToggleOne(response: OnboardingAgreement.ToggleOne.Response) {
        let agreement = response.agreements[response.index]
        let displayed = DisplayedAgreement(title: agreement.title, isChecked: agreement.isChecked)
        let isAllChecked = response.agreements.allSatisfy { $0.isChecked }
        let isNextEnabled = response.agreements.filter { $0.isRequired }.allSatisfy { $0.isChecked }
        
        let viewModel = OnboardingAgreement.ToggleOne.ViewModel(
            displayedAgreement: displayed,
            index: response.index,
            isAllChecked: isAllChecked,
            isNextEnabled: isNextEnabled
        )
        viewController?.displayToggleOne(viewModel: viewModel)
    }
}
