//
//  ViewController.swift
//  GuavapayPaymentSDKDemo
//
//  Created by Nikolay Spiridonov on 05.06.2025.
//

import UIKit
import GuavapayPaymentSDK

final class ViewController: UIViewController {

    private let transition = BottomSheetTransitioningDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let sheetVC = PaymentSheetViewController()
            sheetVC.modalPresentationStyle = .custom
            sheetVC.transitioningDelegate = self.transition
            self.present(sheetVC, animated: true)
        }
    }
}
