//
//  PopupAssembly.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class PopupAssembly {
    static func assemble(config: PopupConfig) -> UIViewController {
        let interactor = PopupInteractor()
        let viewController = PopupViewController()
        let router = PopupRouter(view: viewController)
        let presenter = PopupPresenter(
            interactor: interactor,
            view: viewController,
            router: router,
            config: config
        )

        viewController.output = presenter
        interactor.output = presenter

        return viewController
    }
}
