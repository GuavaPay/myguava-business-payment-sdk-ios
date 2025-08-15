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
    var onCVVCodeEndEditing: ((String) -> Void)?

    private lazy var cvvInputField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.delegate = self
        textField.keyboardType = .numberPad
        textField.font = .body1Regular
        textField.textColor = UICustomization.Input.textColor
        textField.attributedPlaceholder = NSAttributedString(
            string: "CVV",
            attributes: [
                .foregroundColor: UICustomization.Input.placeholderTextColor
            ]
        )
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
        let view = ThemedInputContainerView()
        view.backgroundColor = UICustomization.Input.backgroundColor
        view.layer.cornerRadius = UICustomization.Input.cornerRadius
        view.layer.borderWidth = UICustomization.Input.borderWidth
        view.layer.borderColor = UICustomization.Input.borderColor.cgColor
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

    private var actualCVV: String = ""
    private var maskTimer: Timer?

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

    func showMaskedCVVWithLastDigitVisible() {
        maskTimer?.invalidate()

        let masked = String(repeating: "*", count: max(0, actualCVV.count - 1))
        let display = masked + actualCVV.suffix(1)
        cvvInputField.text = display

        maskTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.cvvInputField.text = String(repeating: "*", count: self.actualCVV.count)
        }
    }
}

// MARK: - UITextFieldDelegate

extension CVVCodeInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let current = actualCVV as NSString? else { return false }

        let isDeleting = string.isEmpty

        if isDeleting {
            actualCVV = current.replacingCharacters(in: range, with: "")
            cvvInputField.text = String(repeating: "*", count: actualCVV.count)
            return false
        }

        let cleanInput = string.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        let newValue = current.replacingCharacters(in: range, with: cleanInput)
        if newValue.count > 4 { return false }

        actualCVV = newValue
        showMaskedCVVWithLastDigitVisible()
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onCVVCodeEndEditing?(actualCVV)
    }
}
