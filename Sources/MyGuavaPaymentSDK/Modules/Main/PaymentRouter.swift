//
//  PaymentRouter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit

final class PaymentRouter {

    private(set) weak var rootController: UIViewController?

     // MARK: - Init

    init(view: UIViewController) {
        rootController = view
    }

}

// MARK: - PaymentRouterInput

extension PaymentRouter: PaymentRouterInput {
    func openSelectCountry(selectedCountry: CountryResponse?, output: SelectCountryCodeModuleOutput?) {
        rootController?.presentController(
            SelectCountryCodeAssembly.assemble(selectedItem: selectedCountry, output: output)
        )
    }

    func openQRCodeScanner(title: String, output: QRCodeScannerModuleOutput?) {
        let viewController = QRCodeScannerAssembly.assemble(title: title, output: output)
        viewController.modalPresentationStyle = .fullScreen
        rootController?.presentController(viewController)
    }

    func showCardScanner(output: CardScannerDelegate) {
        let viewController = CardScannerViewController(delegate: output)
        viewController.modalPresentationStyle = .fullScreen
        rootController?.presentController(viewController)
    }

    func showPopup(cardName: String, deleteAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        let deleteButton = Button(
            config: Button.Config(
                type: .text("Delete"),
                state: .enabled,
                scheme: .danger,
                size: .large
            )
        )
        let cancelButton = Button(
            config: Button.Config(
                type: .text("Cancel"),
                state: .enabled,
                scheme: .secondary,
                size: .large
            )
        )
        let config = PopupConfig(
            title: "Are you sure you want to delete the card?",
            message: "Are you sure you want to delete \(cardName)? This action cannot be undone.",
            buttons: [
                deleteButton,
                cancelButton
            ]
        )
        let popup = PopupAssembly.assemble(config: config)

        deleteButton.setAction {
            popup.dismiss(animated: true)
            deleteAction?()
        }

        cancelButton.setAction {
            popup.dismiss(animated: true)
            cancelAction?()
        }

        rootController?.presentController(popup)
    }

    func showEditCardNamePopup(
        saveAction: (() -> Void)?,
        cancelAction: (() -> Void)?,
        editCardName: ((String) -> Void)?
    ) {
        let saveButton = Button(
            config: Button.Config(
                type: .text("Save"),
                state: .enabled,
                scheme: .primary,
                size: .large
            )
        )
        let cancelButton = Button(
            config: Button.Config(
                type: .text("Cancel"),
                state: .enabled,
                scheme: .secondary,
                size: .large
            )
        )
        let config = PopupConfig(
            title: "Rename card",
            buttons: [
                saveButton,
                cancelButton
            ]
        )
        let popup = EditCardNamePopupAssembly.assemble(config: config, editCardName: editCardName)

        saveButton.setAction {
            popup.dismiss(animated: true)
            saveAction?()
        }

        cancelButton.setAction {
            popup.dismiss(animated: true)
            cancelAction?()
        }

        rootController?.presentController(popup)
    }
    
    func showErrorConnectionPopup(
        title: String,
        subtitle: String,
        cancelAction: @escaping () -> Void
    ) {
        let cancelButton = Button(
            config: Button.Config(
                type: .text("Cancel"),
                state: .enabled,
                scheme: .secondary,
                size: .large
            )
        )
        let config = PopupConfig(
            title: title,
            message: subtitle,
            buttons: [
                cancelButton
            ]
        )
        let popup = PopupAssembly.assemble(config: config)

        cancelButton.setAction {
            popup.dismiss(animated: true)
            cancelAction()
        }
        rootController?.presentController(popup)
    }
}
