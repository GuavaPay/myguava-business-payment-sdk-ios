//
//  BottomSheetTransitioningDelegate.swift
//  GuavapayPaymentSDK
//
//  Created by Nikolay Spiridonov on 05.06.2025.
//

import Foundation
import UIKit

public final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }

    public func animationController(
        forPresented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        BottomSheetAnimator(isPresenting: true)
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        BottomSheetAnimator(isPresenting: false)
    }
}
