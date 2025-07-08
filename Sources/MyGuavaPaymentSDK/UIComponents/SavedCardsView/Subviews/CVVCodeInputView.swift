//
//  CVVCodeInputView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 20.06.2025.
//

import UIKit
import SnapKit

final class CVVCodeInputView: UIView {

    var maxLength: Int = 3

    private lazy var cvvInputField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.delegate = self
        textField.placeholder = "CVV"
        textField.keyboardType = .numberPad
        textField.font = .body1Regular
        textField.textColor = .label
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.setLeftPadding(12)
        return textField
    }()

    private let cardIconImageView: UIImageView = {
        let imageView = UIImageView(image: Icons.securityCard)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.input.borderRest.cgColor
        return view
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        stack.distribution = .fill
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(containerView)

        containerView.addSubview(contentStack)
        contentStack.addArrangedSubview(cvvInputField)
        contentStack.addArrangedSubview(cardIconImageView)

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12))
        }

        cardIconImageView.snp.makeConstraints {
            $0.width.equalTo(34)
            $0.height.equalTo(32)
        }
    }

    func getCVV() -> String {
        return cvvInputField.text ?? ""
    }

    func isValidCVV() -> Bool {
        let regex = #"^\d{3,4}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: getCVV())
    }
}

// MARK: - UITextFieldDelegate

extension CVVCodeInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let current = textField.text, let range = Range(range, in: current) else { return false }

        let updated = current.replacingCharacters(in: range, with: string)
        let digits = updated.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)

        if digits.count > maxLength { return false }

        textField.text = digits
        return false
    }
}

