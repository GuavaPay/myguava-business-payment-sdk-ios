//
//  PaymentSheetViewController.swift
//  GuavapayPaymentSDK
//
//  Created by Nikolay Spiridonov on 09.06.2025.
//

import UIKit
import PassKit

public final class PaymentSheetViewController: UIViewController {

    private let scrollView = UIScrollView()

    private let content = UIStackView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        setupLayout()
        assembleContent()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let targetHeight = content.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0)).height + 48
        preferredContentSize = CGSize(width: 0, height: targetHeight)
    }
}

private extension PaymentSheetViewController {
    func setupViewHierarchy() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        content.axis = .vertical
        content.spacing = 24
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    func assembleContent() {
        content.addArrangedSubview(headerSection())
        content.addArrangedSubview(divider(label: "Or pay by card"))

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1200).isActive = true
        content.addArrangedSubview(view)
    }
}

private extension PaymentSheetViewController {
    func headerSection() -> UIView {
        let closeButton = UIButton(type: .system)
        closeButton
            .setImage(UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)

        let applePayButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let h = UIStackView(arrangedSubviews: [closeButton, UIView(), applePayButton])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        return h
    }
    
    @objc
    func handleDismiss() {
        dismiss(animated: true)
    }

    func divider(label text: String) -> UIView {
        let lineLeft  = UIView()
        lineLeft.backgroundColor  = .tertiarySystemFill

        let lineRight = UIView()
        lineRight.backgroundColor = .tertiarySystemFill

        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel

        let h = UIStackView(arrangedSubviews: [lineLeft, label, lineRight])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 8
        lineLeft.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineRight.heightAnchor.constraint(equalTo: lineLeft.heightAnchor).isActive = true

        return h
    }
}
