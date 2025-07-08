//
//  EditCardNamePopupProtocols.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import Foundation

protocol EditCardNamePopupViewInput: AnyObject {
    func setConfig(_ config: PopupConfig)
}

protocol EditCardNamePopupViewOutput: AnyObject {
    func viewDidLoad()
    func buttonTapped()
    func backgroundTapped()
    func didChangeCardNameText(_ text: String)
}

protocol EditCardNamePopupInteractorInput: AnyObject {}

protocol EditCardNamePopupInteractorOutput: AnyObject {}

protocol EditCardNamePopupRouterInput: Router {
    func dismissPopup()
}

protocol EditCardNamePopupModuleInput: AnyObject {
    func configure(_ output: PopupConfig)
}
