//
//  BottomSheetAnimator.swift
//  GuavapayPaymentSDK
//
//  Created by Nikolay Spiridonov on 05.06.2025.
//

import Foundation
import UIKit

final class BottomSheetAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.35
    }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewKey = isPresenting ? .to : .from
        guard let sheet = ctx.view(forKey: key) else { return }
        let container = ctx.containerView

        if isPresenting {
            container.addSubview(sheet)
            let finalFrame = ctx.finalFrame(for: ctx.viewController(forKey: .to)!)
            sheet.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)
            UIView.animate(
                withDuration: transitionDuration(using: ctx),
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.8,
                options: [.curveEaseOut]
            ) {
                sheet.frame = finalFrame
            } completion: {
                ctx.completeTransition($0)
            }
        } else {
            let start = sheet.frame
            UIView.animate(withDuration: transitionDuration(using: ctx)) {
                sheet.frame = start.offsetBy(dx: 0, dy: start.height)
            } completion: { _ in
                ctx.completeTransition(true)
            }
        }
    }
}
