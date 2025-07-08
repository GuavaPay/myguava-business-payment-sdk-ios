//
//  EditCardNamePopupAssembly.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class EditCardNamePopupAssembly {
    static func assemble(config: PopupConfig, editCardName: ((String) -> Void)?) -> UIViewController {
        let interactor = EditCardNamePopupInteractor()
        let viewController = EditCardNamePopupViewController()
        let router = EditCardNamePopupRouter(view: viewController)
        let presenter = EditCardNamePopupPresenter(
            interactor: interactor,
            view: viewController,
            router: router,
            config: config
        )

        presenter.editCardName = editCardName

        viewController.output = presenter
        interactor.output = presenter

        return viewController
    }
}
