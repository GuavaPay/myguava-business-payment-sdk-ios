//
//  CardholderNameFieldView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 25.07.2025.
//

import UIKit

final class CardholderNameFieldView: UIView {

    var onTextChanged: ((String) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Cardholder name"
        label.textColor = UICustomization.Label.textColor
        label.font = .body1Regular
        label.isSkeletonable = true
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.autocapitalizationType = .allCharacters
        textField.keyboardType = .asciiCapable
        textField.attributedPlaceholder = NSAttributedString(
            string: "CARDHOLDER NAME",
            attributes: [.foregroundColor: UICustomization.Input.placeholderTextColor]
        )
        textField.font = .body1Regular
        textField.textColor = UICustomization.Input.textColor
        textField.borderStyle = .none
        textField.setLeftPadding(10)
        return textField
    }()

    private let containerView: UIView = {
        let view = ThemedInputContainerView()
        view.backgroundColor = UICustomization.Input.backgroundColor
        view.layer.cornerRadius = UICustomization.Input.cornerRadius
        view.layer.borderWidth = UICustomization.Input.borderWidth
        view.layer.borderColor = UICustomization.Input.borderColor.cgColor
        view.isSkeletonable = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(containerView)

        containerView.addSubview(textField)

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(12)
        }

        textField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func showLoading() {
        containerView.layer.borderWidth = 0
        startShimmering()
    }

    func hideLoading() {
        containerView.layer.borderWidth = 1
        stopShimmering()
    }

    func disable() {
        textField.isEnabled = false
    }
}

extension CardholderNameFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else { return false }

        let replacement = string.uppercased()

        let allowedCharacters = CharacterSet.uppercaseLetters.union(.whitespaces)
        if replacement.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: replacement)
        if updatedText.count > 25 {
            return false
        }

        let wordCount = updatedText.split(separator: " ").count
        if wordCount > 2 {
            return false
        }

        if replacement == " " {
            if range.location == 0 {
                return false
            }

            if currentText.contains(" ") {
                return false
            }

            let indexBefore = currentText.index(currentText.startIndex, offsetBy: range.location - 1)
            if !currentText[indexBefore].isLetter {
                return false
            }
            return true
        }

        textField.text = updatedText
        onTextChanged?(textField.text ?? "")
        return false
    }
}


// MARK: - CardExpirationDateFieldView + ShimmerableView

extension CardholderNameFieldView: ShimmerableView {
    var shimmeringViews: [UIView] {
        [titleLabel, containerView]
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [titleLabel: .automatic]
    }
}

// MARK: - CardholderNameFieldView + KeyboardToolbarable

extension CardholderNameFieldView: KeyboardToolbarable {
    var firstResponderInput: UITextField {
        textField
    }
}

