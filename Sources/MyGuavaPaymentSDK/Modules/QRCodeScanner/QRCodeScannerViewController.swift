//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import UIKit

final class QRCodeScannerViewController: UIViewController {

    private let customView = QRCodeScannerView()

    var output: QRCodeScannerViewOutput?

    override func loadView() {
        super.loadView()
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        output?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customView.viewDidLayoutSubviews()
    }

    private func configure() {
        configureCustomView()
    }

    private func configureCustomView() {
        customView.onBack = { [weak self] in
            self?.output?.didPressBack()
        }

        customView.onFlash = { [weak self] in
            self?.output?.didPressFlash()
        }

        customView.onFound = { [weak self] value in
            self?.output?.onFound(value)
        }
    }
}

// MARK: QRCodeScannerViewInput

extension QRCodeScannerViewController: QRCodeScannerViewInput {
    func updateTitle(_ title: String) {
        customView.updateTitle(title)
    }

    func startSession() {
        customView.startSession()
    }

    func stopSession() {
        customView.stopSession()
    }

    func updateFlash(_ isOn: Bool) {
        customView.updateFlash(isOn)
    }
}
