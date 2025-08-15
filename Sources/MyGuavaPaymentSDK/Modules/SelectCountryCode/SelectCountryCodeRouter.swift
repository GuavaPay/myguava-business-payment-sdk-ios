//
//  SelectCountryCodeRouter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit

final class SelectCountryCodeRouter {

    private(set) weak var rootController: UIViewController?

    // MARK: - Init

    init(view: UIViewController) {
        rootController = view
    }

}

// MARK: - SelectCountryCodeRouterInput

extension SelectCountryCodeRouter: SelectCountryCodeRouterInput {
    func close() {
        rootController?.dismiss(animated: true)
    }
}
