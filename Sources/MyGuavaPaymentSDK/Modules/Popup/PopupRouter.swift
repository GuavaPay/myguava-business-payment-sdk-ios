//
//  PopupRouter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class PopupRouter {
    private(set) weak var rootController: UIViewController?

    // MARK: - Init

    init(view: UIViewController) {
        rootController = view
    }

}

// MARK: - PopupRouterInput

extension PopupRouter: PopupRouterInput {
    func dismissPopup() {
        rootController?.dismiss(animated: true, completion: nil)
    }
}
