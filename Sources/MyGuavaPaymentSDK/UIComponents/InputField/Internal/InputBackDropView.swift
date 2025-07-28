//
//  InputBackDropView.swift
//
//
//  Created by Mikhail Kirillov on 18/6/24.
//

import UIKit

class InputBackDropView: UIView {

    private let containerView = UIView()
    private var trailingContentConstraint = NSLayoutConstraint()
    private var style: Style

    init(state: InputField.State, style: Style, view: UIView? = nil) {
        self.style = style
        super.init(frame: .zero)

        configureView(padding: style.padding)
        updateView(with: style)

        if let view  {
            setContentView(view)
        }
    }

    func applyStyle(_ style: Style) {
        self.style = style
        updateView(with: style)
        setRightPadding(style.padding.right)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyStyle(style)
    }

    func setContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        containerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        ])
    }

    func setRightPadding(_ value: CGFloat) {
        trailingContentConstraint.constant = -value
    }

    private func configureView(padding: UIEdgeInsets) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        trailingContentConstraint = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, 
                                                                            constant: -padding.right)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
            trailingContentConstraint
        ])
    }

    private func updateView(with style: Style) {
        backgroundColor = style.backgroundColor
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.resolvedCGColor(traitCollection)
        setRightPadding(style.padding.right)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = style.cornerRadius == .full ? bounds.height / 2 : style.cornerRadius
    }
}
