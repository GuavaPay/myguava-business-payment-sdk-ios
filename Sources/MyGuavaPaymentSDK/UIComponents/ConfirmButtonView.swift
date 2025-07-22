//
//  ConfirmButtonView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 11.06.2025.
//

import UIKit
import SnapKit

final class ConfirmButtonView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pay $20.00"
        label.textColor = UICustomization.Label.textColor
        label.font = .body1Semibold
        label.textAlignment = .center
        return label
    }()

    /// Callback при нажатии
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupLayout() {
        backgroundColor = UICustomization.Button.backgroundColor
        layer.cornerRadius = UICustomization.Button.cornerRadius
        clipsToBounds = true
        isUserInteractionEnabled = true

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        onTap?()
    }
}

