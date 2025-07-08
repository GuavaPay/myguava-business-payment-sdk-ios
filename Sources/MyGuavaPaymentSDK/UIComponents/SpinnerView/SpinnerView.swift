//
//  SpinnerView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit

public final class SpinnerView: UIView {

    private var style: Style {
        Self.StockStyle.getStyle()
    }

    private var strokeColor: UIColor? {
        didSet {
            applyStyle(strokeColor)
        }
    }

    private let arcLayer = CAShapeLayer()
    private let animationKey = "rotationAnimation"

    private var size: Size
    private let thicknessMultiplier = 0.0999
    private let willBeShownOnOverlay: Bool

    /// Init for spinner view
    /// - Parameters:
    ///   - size: choose spinner size
    ///   - willBeShownOnOverlay: boolean, that needed if we show spinner on the overlay. Set it to true, if u need add it to overlay. It will take correct colors for spinner.
    public init(size: Size, willBeShownOnOverlay: Bool = false) {
        self.size = size
        self.willBeShownOnOverlay = willBeShownOnOverlay
        super.init(frame: CGRect(origin: .zero,
                                 size: CGSize(width: size.rawValue, height: size.rawValue)))
        setupLayer()
    }

    override init(frame: CGRect) {
        self.size = .small
        self.willBeShownOnOverlay = false
        super.init(frame: CGRect(origin: .zero,
                                 size: CGSize(width: size.rawValue, height: size.rawValue)))
        setupLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayer() {
        let startAngle = CGFloat(0)
        let endAngle = CGFloat(3 * Double.pi / 2)
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                   radius: (bounds.width - 3) / 2,
                                   startAngle: startAngle,
                                   endAngle: endAngle,
                                   clockwise: true)

        arcLayer.path = arcPath.cgPath
        arcLayer.lineWidth = size.rawValue * thicknessMultiplier
        arcLayer.lineCap = .round

        applyStyle()

        layer.addSublayer(arcLayer)

        startAnimating()
    }

    private func applyStyle(_ strokeColor: UIColor? = nil) {
        if willBeShownOnOverlay {
            arcLayer.strokeColor = UIColor.foreground.onAccent.cgColor
        } else {
            arcLayer.strokeColor = strokeColor?.cgColor ?? style.borderStrokeColor.cgColor
        }

        arcLayer.fillColor = style.borderFillColor.cgColor
    }

    // MARK: - Public methods

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        applyStyle(strokeColor)
    }

    public func startAnimating() {
        if arcLayer.animation(forKey: animationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0
            rotationAnimation.toValue = 2 * CGFloat.pi
            rotationAnimation.duration = 1.5
            rotationAnimation.repeatCount = .infinity
            rotationAnimation.isRemovedOnCompletion = false

            arcLayer.add(rotationAnimation, forKey: animationKey)
        }
    }

    private func updateArcPath() {
        let startAngle = CGFloat(0)
        let endAngle = CGFloat(3 * Double.pi / 2)
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                   radius: (bounds.width - 3) / 2,
                                   startAngle: startAngle,
                                   endAngle: endAngle,
                                   clockwise: true)
        arcLayer.path = arcPath.cgPath
        arcLayer.frame = bounds
        arcLayer.lineWidth = size.rawValue * thicknessMultiplier
        arcLayer.shadowPath = arcPath.cgPath
    }

    public func setSize(_ size: Size) {
        self.size = size
        self.invalidateIntrinsicContentSize()
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(origin: self.frame.origin, size: self.intrinsicContentSize)
        }) { _ in
            self.updateArcPath()
        }
    }

    public func setColor(_ color: UIColor) {
        strokeColor = color
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: size.rawValue, height: size.rawValue)
    }

    public func stopAnimating() {
        arcLayer.removeAnimation(forKey: animationKey)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateArcPath()
    }
}

