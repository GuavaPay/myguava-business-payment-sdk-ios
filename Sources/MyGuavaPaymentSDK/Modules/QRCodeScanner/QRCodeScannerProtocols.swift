//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import class UIKit.UIViewController

protocol QRCodeScannerViewInput: AnyObject {
    func updateTitle(_ title: String)
    func startSession()
    func stopSession()
    func updateFlash(_ isOn: Bool)
}

protocol QRCodeScannerViewOutput: AnyObject {
    func viewDidLoad()
    func didPressBack()
    func didPressFlash()
    func onFound(_ value: String)
}


protocol QRCodeScannerRouterInput: AnyObject {

    func close()
}

protocol QRCodeScannerModuleInput: AnyObject {

    func configure(_ output: QRCodeScannerModuleOutput?)
}

protocol QRCodeScannerModuleOutput: AnyObject {

    func didScanCode(foundValue: String)
}
