//
//  ShimmerableView.swift
//
//
//  Created by Nihad Samedov on 9/5/24.
//

import UIKit
import SkeletonView

/// Settings for shimmer loading appearance configuration
public enum ShimmerableViewConfiguration {
    /// Corner radius to be set on views, labels are calculated automatically with following formula: label.font.pointSize / 2
    public enum ViewCornerRadius {
        /// Uses view's itself's corner radius
        case asView
        /// Uses corner radius passed to the argument for shimmer
        /// - Parameter Int: corner radius to be set on view
        case value(Int)
        /// Automatically determines corner radius based on view's frame height
        case automatic
    }
}

/// Protocol for views which need shimmer loading support
public protocol ShimmerableView {
    /// Views which need to be shimmered
    var shimmeringViews: [UIView] { get }

    /// Customizable corner radius for views, for views which are not in this list, but are in shimmeringViews list would be applied asView corner radius configuration, meaning corner radius is same as View's
    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] { get }

    /// Starts shimmer loading gradient animation for all shimmeringViews
    func startShimmering()

    /// Starts shimmer loading for specific views
    /// - Important: all 'views' should be inside 'shimmeringViews', otherwise 'views' will not start shimmering
    func startShimmering(for views: [UIView])

    /// Stops shimmer loading gradient animation for all shimmeringViews
    func stopShimmering()

    /// Stops shimmer loading for specific views
    /// - Important: All 'views' should be inside 'shimmeringViews', otherwise 'views' will not stop shimmering
    func stopShimmering(for views: [UIView])

    /// Updates shimmer loading colors for all shimmeringViews
    func updateShimmerColors()
}

// MARK: - ShimmerableView default implementation

public extension ShimmerableView {
    private static var gradient: SkeletonGradient {
        SkeletonGradient(baseColor: .other.shimmerBase, secondaryColor: .other.shimmerGlow)
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        var cornerRadiuses: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] = [:]
        for view in shimmeringViews {
            cornerRadiuses[view] = .asView
        }
        return cornerRadiuses
    }

    func startShimmering() {
        startShimmering(for: shimmeringViews)
    }

    func startShimmering(for views: [UIView]) {
        views.forEach { view in
            guard shimmeringViews.contains(view) else {
                return
            }

            view.layoutIfNeeded()

            if !view.isSkeletonable {
                view.isSkeletonable = true
            }

            if let label = view as? UILabel {
                if Int(label.skeletonCornerRadius) > SkeletonAppearance.default.multilineCornerRadius {
                    label.linesCornerRadius = Int(label.skeletonCornerRadius)
                } else {
                    label.linesCornerRadius = Int(label.font.pointSize / 2)
                }
            } else if let cornerRadius = shimmeringViewsCornerRadius[view] {
                switch cornerRadius {
                case .asView:
                    view.skeletonCornerRadius = Float(view.layer.cornerRadius)
                case .value(let cornerRadius):
                    view.skeletonCornerRadius = Float(cornerRadius)
                case .automatic:
                    view.skeletonCornerRadius = Float(view.frame.height * 0.4)
                }
            } else {
                view.skeletonCornerRadius = Float(view.layer.cornerRadius)
            }

            DispatchQueue.main.async {
                let customAnimation = SkeletonAnimationBuilder().makeCustomShimmerAnimationWithDelay()
                view.showAnimatedGradientSkeleton(usingGradient: Self.gradient, animation: customAnimation, transition: .none)
            }
        }
    }


    func stopShimmering() {
        stopShimmering(for: shimmeringViews)
    }

    func stopShimmering(for views: [UIView]) {
        DispatchQueue.main.async {
            views.forEach { view in
                guard shimmeringViews.contains(view) else {
                    return
                }

                view.hideSkeleton(reloadDataAfter: false, transition: .none)
            }
        }
    }

    func updateShimmerColors() {
        DispatchQueue.main.async {
            for view in shimmeringViews where view.sk.isSkeletonActive {
                let customAnimation = SkeletonAnimationBuilder().makeCustomShimmerAnimationWithDelay()
                view.updateAnimatedGradientSkeleton(usingGradient: Self.gradient, animation: customAnimation)
            }
        }
    }
}

// MARK: - Animation configuration

private extension SkeletonAnimationBuilder {
    func makeCustomShimmerAnimationWithDelay(
        duration: CFTimeInterval = 0.8,
        delay: CFTimeInterval = 0.5
    ) -> SkeletonLayerAnimation {
        { _ in
            let direction = LeftRightGradientAnimationDirection()

            let startPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
            startPointAnim.fromValue = direction.startPoint.from
            startPointAnim.toValue = direction.startPoint.to
            startPointAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

            let endPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
            endPointAnim.fromValue = direction.endPoint.from
            endPointAnim.toValue = direction.endPoint.to
            endPointAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

            let startAndEndPointAnimationGrop = CAAnimationGroup()
            startAndEndPointAnimationGrop.animations = [startPointAnim, endPointAnim]
            startAndEndPointAnimationGrop.duration = duration
            startAndEndPointAnimationGrop.fillMode = .both

            // To add delay after animation we add our animation group to another group. It let's to use duration with delay like in design
            let animationGroupWithDelay = CAAnimationGroup()
            animationGroupWithDelay.animations = [startAndEndPointAnimationGrop]
            animationGroupWithDelay.duration = duration + delay
            animationGroupWithDelay.repeatCount = .infinity
            animationGroupWithDelay.isRemovedOnCompletion = false
            animationGroupWithDelay.beginTime = 0

            return animationGroupWithDelay
        }
    }
}

private struct LeftRightGradientAnimationDirection {
    typealias GradientAnimationPoint = (from: CGPoint, to: CGPoint)

    var startPoint: GradientAnimationPoint {
        (from: CGPoint(x: -1, y: 0.5), to: CGPoint(x: 1, y: 0.5))
    }

    var endPoint: GradientAnimationPoint {
        (from: CGPoint(x: 0, y: 0.5), to: CGPoint(x: 2, y: 0.5))
    }
}
