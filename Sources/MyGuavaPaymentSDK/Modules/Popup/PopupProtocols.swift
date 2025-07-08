//
//  PopupProtocols.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import Foundation

protocol PopupViewInput: AnyObject {
    func setConfig(_ config: PopupConfig)
}

protocol PopupViewOutput: AnyObject {
    func viewDidLoad()
    func buttonTapped()
    func backgroundTapped()
}

protocol PopupInteractorInput: AnyObject {}

protocol PopupInteractorOutput: AnyObject {}

protocol PopupRouterInput: Router {
    func dismissPopup()
}

protocol PopupModuleInput: AnyObject {
    func configure(_ output: PopupConfig)
}
