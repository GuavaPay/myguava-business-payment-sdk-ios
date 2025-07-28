//
//  RadioButtonView.swift
//
//
//  Created by Ignat Chegodaykin on 06.06.2024.
//

import UIKit

final class RadioButtonView: UIView {

    private let strokeLayer = CAShapeLayer()
    private let checkLayer = CAShapeLayer()

    let style: RadioButtonStyleProtocol = RadioButtonStyle()

    var onChecked: Bool = false {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            configureColors()
            CATransaction.commit()
        }
    }

    var isEnabled: Bool = true {
        didSet {
            configureColors()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureColors()
    }

    private func setupView() {
        backgroundColor = .clear

        layer.cornerRadius = style.commonCornerRadius

        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.lineWidth = 2

        strokeLayer.path = UIBezierPath(
            roundedRect: CGRect(
                x: 0,
                y: 0,
                width: style.commonSize.width,
                height: style.commonSize.height
            ),
            cornerRadius: style.commonCornerRadius
        ).cgPath

        checkLayer.path = UIBezierPath(
            roundedRect: CGRect(
                x: (style.commonSize.width / 2) - ((style.checkSize.width) / 2),
                y: (style.commonSize.height / 2) - ((style.checkSize.height) / 2),
                width: style.checkSize.width,
                height: style.checkSize.height
            ),
            cornerRadius: style.checkCornerRadius
        ).cgPath

        configureColors()

        layer.addSublayer(strokeLayer)
        layer.addSublayer(checkLayer)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle)))
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: style.commonSize.width),
            heightAnchor.constraint(equalToConstant: style.commonSize.height),
        ])
    }

    private func configureColors() {
        if !isEnabled {
            isUserInteractionEnabled = false
            strokeLayer.strokeColor = style.borderDisabledColor.resolvedCGColor(traitCollection)
            checkLayer.fillColor = onChecked ? style.borderDisabledColor.cgColor : UIColor.clear.cgColor
            layer.backgroundColor = style.backgroundDisabledColor.cgColor
        } else {
            strokeLayer.strokeColor = onChecked ? style.borderCheckedColor.cgColor : style.borderUnCheckedColor.cgColor
            checkLayer.fillColor = onChecked ? style.borderCheckedColor.cgColor : UIColor.clear.cgColor
            layer.backgroundColor = UIColor.clear.cgColor
        }
    }

    @objc
    func toggle() {
        onChecked.toggle()
    }
}
