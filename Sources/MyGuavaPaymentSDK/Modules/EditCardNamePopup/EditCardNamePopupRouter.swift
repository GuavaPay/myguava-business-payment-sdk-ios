//
//  EditCardNamePopupRouter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class EditCardNamePopupRouter {
    private(set) weak var rootController: UIViewController?

     // MARK: - Init

    init(view: UIViewController) {
        rootController = view
    }

}

// MARK: - EditCardNamePopupRouterInput

extension EditCardNamePopupRouter: EditCardNamePopupRouterInput {
    func dismissPopup() {
        rootController?.dismiss(animated: true, completion: nil)
    }
}
