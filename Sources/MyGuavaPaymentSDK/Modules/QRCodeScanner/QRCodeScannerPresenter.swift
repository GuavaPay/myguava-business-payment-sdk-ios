//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import Foundation

final class QRCodeScannerPresenter {

    private weak var view: QRCodeScannerViewInput?
    private let router:QRCodeScannerRouterInput
    private var moduleOutput: QRCodeScannerModuleOutput?

    private let title: String
    private(set) var flashIsOn: Bool = false

    init(
        view:  QRCodeScannerViewInput,
        router:  QRCodeScannerRouterInput,
        title: String
    ) {
        self.view = view
        self.router = router
        self.title = title
    }
}

// MARK: QRCodeScannerViewOutput

extension QRCodeScannerPresenter: QRCodeScannerViewOutput {
    func viewDidLoad() {
        view?.updateTitle(title)
        view?.startSession()
    }

    func didPressBack() {
        view?.stopSession()
        router.close()
    }

    func didPressFlash() {
        flashIsOn = !flashIsOn
        view?.updateFlash(flashIsOn)
    }

    func onFound(_ value: String) {
        view?.stopSession()
        moduleOutput?.didScanCode(foundValue: value)
        router.close()
    }
}

// MARK: - QRCodeScannerModuleInput

extension QRCodeScannerPresenter: QRCodeScannerModuleInput {
    func configure(_ output: QRCodeScannerModuleOutput?) {
        moduleOutput = output
    }
}
