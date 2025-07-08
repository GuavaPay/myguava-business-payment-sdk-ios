//
//  StackView+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 11.06.2025.
//

import UIKit

extension UIStackView {
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { view in
            removeFully(view: view)
        }
    }

    func removeSafelyArrangedSubview(_ view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }

    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }

    func safelyRemoveArrangedSubviews() {
        // Remove all the arranged subviews and save them to an array
        let removedSubviews = arrangedSubviews.reduce([]) { sum, next -> [UIView] in
            self.removeArrangedSubview(next)
            return sum + [next]
        }

        NSLayoutConstraint.deactivate(removedSubviews.flatMap {
            $0.constraints
        })

        removedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }

    func insertArrangedSubview(_ view: UIView, belowArrangedSubview subview: UIView) {
        arrangedSubviews.enumerated().forEach {
            if $0.1 == subview {
                insertArrangedSubview(view, at: $0.0 + 1)
            }
        }
    }

    func insertArrangedSubview(_ view: UIView, aboveArrangedSubview subview: UIView) {
        arrangedSubviews.enumerated().forEach {
            if $0.1 == subview {
                insertArrangedSubview(view, at: $0.0)
            }
        }
    }
}
