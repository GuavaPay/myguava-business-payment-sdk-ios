//
//  EditCardNamePopupPresenter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import Foundation

final class EditCardNamePopupPresenter {

    var editCardName: ((String) -> Void)?
    private let interactor: EditCardNamePopupInteractorInput
    private weak var view: EditCardNamePopupViewInput?
    private let router: EditCardNamePopupRouterInput
    private let config: PopupConfig

    init(
        interactor: EditCardNamePopupInteractorInput,
        view: EditCardNamePopupViewInput,
        router: EditCardNamePopupRouterInput,
        config: PopupConfig
    ) {
        self.interactor = interactor
        self.view = view
        self.router = router
        self.config = config
    }
}

// MARK: - EditCardNamePopupViewOutput

extension EditCardNamePopupPresenter: EditCardNamePopupViewOutput {
    func viewDidLoad() {
        view?.setConfig(config)
    }

    func buttonTapped() {
        router.dismissPopup()
    }

    func backgroundTapped() {
        router.dismissPopup()
    }

    func didChangeCardNameText(_ text: String) {
        editCardName?(text)
    }
}

// MARK: - EditCardNamePopupInteractorOutput

extension EditCardNamePopupPresenter: EditCardNamePopupInteractorOutput {}
