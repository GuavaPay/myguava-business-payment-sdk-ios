//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import class UIKit.UIViewController

final class QRCodeScannerAssembly {
    static func assemble(
        title: String,
        output: QRCodeScannerModuleOutput? = nil
    ) -> UIViewController {

        let viewController = QRCodeScannerViewController()
        let router = QRCodeScannerRouter(
            view: viewController
        )
        let presenter = QRCodeScannerPresenter(
            view: viewController,
            router: router,
            title: title
        )
        presenter.configure(output)
        viewController.output = presenter

        return viewController
    }
}
