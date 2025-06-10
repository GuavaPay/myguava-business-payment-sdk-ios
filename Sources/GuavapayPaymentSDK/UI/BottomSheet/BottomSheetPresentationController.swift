//
//  BottomSheetPresentationController.swift
//  GuavapayPaymentSDK
//
//  Created by Nikolay Spiridonov on 05.06.2025.
//

import Foundation
import UIKit

final class BottomSheetPresentationController: UIPresentationController {

    private let maxHeightRatio: CGFloat = 0.9

    private var dimming = UIView()

    override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        setup()
    }

    deinit {
        presentedViewController.removeObserver(self, forKeyPath: "preferredContentSize")
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView else { return }
        dimming.frame = container.bounds
        container.addSubview(dimming)

        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in self.dimming.alpha = 1 })
        } else {
            dimming.alpha = 1
        }
    }

    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in self.dimming.alpha = 0 })
        } else {
            dimming.alpha = 0
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }

        let target = presentedViewController.preferredContentSize.height
        let maxH = container.bounds.height * maxHeightRatio
        let h = min(max(target, 100), maxH)

        return CGRect(
            x: 0,
            y: container.bounds.height - h,
            width: container.bounds.width,
            height: h
        )
    }

    override func observeValue(
        forKeyPath keyPath: String?, of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "preferredContentSize" {
            presentedView?.frame = frameOfPresentedViewInContainerView

        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.layer.cornerRadius = 20
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView?.clipsToBounds = true
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimming.frame = containerView?.bounds ?? .zero
    }
}

// MARK: - Private

private extension BottomSheetPresentationController {
    func setup() {
        dimming.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        dimming.alpha = 0
        dimming.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))

        presentedViewController.addObserver(
            self, forKeyPath: "preferredContentSize",
            options: .new, context: nil
        )
    }

    @objc func dismiss() {
        presentedViewController.dismiss(animated: true)
    }
}
