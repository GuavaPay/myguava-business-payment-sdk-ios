//
//  SelectCountryCodeAssembly.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

import class UIKit.UIViewController

public final class SelectCountryCodeAssembly {
    public static func assemble(
        selectedItem: CountryResponse?,
        output: SelectCountryCodeModuleOutput? = nil
    ) -> UIViewController {
        let interactor = SelectCountryCodeInteractor()
        let viewController = SelectCountryCodeViewController()
        let router = SelectCountryCodeRouter(
            view: viewController
        )
        let presenter = SelectCountryCodePresenter(
            interactor: interactor,
            view: viewController,
            router: router,
            selectedItem: selectedItem
        )

        presenter.configure(output)
        viewController.output = presenter
        interactor.output = presenter

        return viewController
    }
}
