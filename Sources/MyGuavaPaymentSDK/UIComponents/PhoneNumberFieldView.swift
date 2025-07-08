//
//  PhoneNumberFieldView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 17.06.2025.
//

import UIKit

final class PhoneNumberFieldView: UIView {
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private let inputField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.placeholder = "Phone number"
        textField.font = .body1Regular
        textField.textColor = .input.primaryForeground
        textField.tintColor = .input.secondaryForeground
        textField.backgroundColor = .gray200
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.input.borderRest.cgColor
        textField.setLeftPadding(12)
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        containerStackView.addArrangedSubviews(
           inputField
        )

        addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
        inputField.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
}
