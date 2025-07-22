//
//  EmailFieldView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 17.06.2025.
//

import UIKit

final class EmailFieldView: UIView {
    var email: String = ""

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private let inputField = InputField(placeholderText: "Enter your email")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = UICustomization.Label.textColor
        label.font = .body1Regular
        return label
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
            titleLabel, inputField
        )

        addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }

        inputField.didChangeText = { [weak self] text in
            self?.email = text
        }
        inputField.autoCorrectionType = .no
        inputField.autocapitalizationType = .none

        inputField.didShouldReturn
    }

    func configureValidEmailField(_ isValid: Bool) {
        inputField.state = !isValid ? .error : .enabled
        inputField.setBottomLeftText(!isValid ? "Invalid email" : "")
    }

    func setValue(_ value: String) {
        inputField.setText(value)
    }
}


// MARK: - UITextField's forwarded focus methods

extension EmailFieldView {
    override var canBecomeFirstResponder: Bool {
        inputField.input.canBecomeFirstResponder
    }

    override var isFirstResponder: Bool {
        inputField.input.isFirstResponder
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        inputField.input.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        inputField.input.resignFirstResponder()
    }
}
