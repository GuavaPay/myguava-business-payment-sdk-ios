//
//  PopupPresenter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import Foundation

final class PopupPresenter {

    private let interactor: PopupInteractorInput
    private weak var view: PopupViewInput?
    private let router: PopupRouterInput
    private let config: PopupConfig

    init(
        interactor: PopupInteractorInput,
        view: PopupViewInput,
        router: PopupRouterInput,
        config: PopupConfig
    ) {
        self.interactor = interactor
        self.view = view
        self.router = router
        self.config = config
    }
}

// MARK: - PopupViewOutput

extension PopupPresenter: PopupViewOutput {
    func viewDidLoad() {
        view?.setConfig(config)
    }

    func buttonTapped() {
        router.dismissPopup()
    }

    func backgroundTapped() {
        router.dismissPopup()
    }
}

// MARK: - PopupInteractorOutput

extension PopupPresenter: PopupInteractorOutput {

}
