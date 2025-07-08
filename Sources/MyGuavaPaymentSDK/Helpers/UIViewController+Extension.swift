//
//  UIViewController+Extension.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit

extension UIViewController {

    func presentModally(
        _ controller: UIViewController,
        transitionStyle: UIModalTransitionStyle = .coverVertical,
        presentationStyle: UIModalPresentationStyle? = nil,
        completion: (() -> Void)? = nil
    ) {
        if let presentationStyle = presentationStyle {
            controller.modalPresentationStyle = presentationStyle
        } else {
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .automatic
            } else {
                controller.modalPresentationStyle = .fullScreen
            }
        }

        controller.modalTransitionStyle = transitionStyle
        present(controller, animated: true, completion: completion)
    }

    func presentController(
        _ controller: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        present(controller, animated: animated, completion: completion)
    }

    func push(
        _ controller: UIViewController
    ) {
        navigationController?.pushViewController(
            controller,
            animated: true
        )
    }

    func close(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        if let navigationController = self.parent as? UINavigationController {
            if navigationController.children.count > 1 {
                guard let controller = navigationController.children.dropLast().last else { return }
                navigationController.popToViewController(controller, animated: animated)
            } else {
                dismiss(animated: animated, completion: completion)
            }
        } else if presentingViewController != nil {
            dismiss(animated: animated, completion: completion)
        }
    }

    func popToRoot(_ animated: Bool = true) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: animated)
        }
    }

    func setRootViewController(_ viewController: UIViewController?) {
        UIApplication.setRootViewController(viewController)
    }

}
