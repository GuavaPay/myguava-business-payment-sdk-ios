//
//  QRCodeScannerRouter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 25.06.2025.
//

import UIKit

final class QRCodeScannerRouter {

    private(set) weak var rootController: UIViewController?

     // MARK: - Init

    init(view: UIViewController) {
        rootController = view
    }

}

// MARK: - QRCodeScannerRouterInput

extension QRCodeScannerRouter: QRCodeScannerRouterInput {
    func close() {
        rootController?.dismiss(animated: true)
    }
}
