//
//  CardExpirationDateFieldView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 12.06.2025.
//

import UIKit
import SnapKit

final class CardExpirationDateFieldView: UIView {

    var onEndEditing: ((_ month: String, _ year: String) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Expiration date"
        label.textColor = UICustomization.Label.textColor
        label.font = .body1Regular
        label.isSkeletonable = true
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: "MM/YY",
            attributes: [
                .foregroundColor: UICustomization.Input.placeholderTextColor
            ]
        )
        textField.keyboardType = .numberPad
        textField.font = .body1Regular
        textField.textColor = UICustomization.Input.textColor
        textField.borderStyle = .none
        textField.setLeftPadding(10)
        textField.addTarget(self, action: #selector(textEditingDidEnd), for: .editingDidEnd)
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

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        showShimmerIfNeeded()
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

    func getExpirationDate() -> String {
        return textField.text ?? ""
    }

    func isValidExpirationDate() -> Bool {
        let regex = #"^(0[1-9]|1[0-2])\/\d{2}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: getExpirationDate())
    }

    func setExpirationDate(_ date: DateComponents) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/YY"
        if let date = Calendar.current.date(from: date) {
            textField.text = formatter.string(from: date)
        }
    }

    func disable() {
        textField.isEnabled = false
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            containerView.layer.borderWidth = 0
            startShimmering()
        } else {
            containerView.layer.borderWidth = 1
            stopShimmering()
        }
    }

    /// Shows shimmer loading
    func showLoading() {
        isLoading = true
    }

    /// Hides shimmer loading
    func hideLoading() {
        isLoading = false
    }

    @objc
    private func textEditingDidEnd() {
        let rawText = textField.text ?? ""
        let comps = rawText.split(separator: "/").map(String.init)
        guard comps.count == 2 else { return }

        onEndEditing?(comps[0], comps[1])
    }
}

extension CardExpirationDateFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else { return false }

        let isDeleting = string.isEmpty
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        let digitsOnly = updatedText.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        let limitedText = String(digitsOnly.prefix(4))

        if isDeleting {
            if currentText.count == 3, range.location == 2 {
                textField.text = String(limitedText.prefix(1))
            } else {
                if limitedText.count <= 2 {
                    textField.text = limitedText
                } else {
                    let month = limitedText.prefix(2)
                    let year = limitedText.suffix(from: limitedText.index(limitedText.startIndex, offsetBy: 2))
                    textField.text = "\(month)/\(year)"
                }
            }
            return false
        }

        if digitsOnly.count == 1 {
            if string != "0" && string != "1" {
                return false
            }
        }

        if digitsOnly.count == 2 {
            let first = digitsOnly.prefix(1)
            let second = digitsOnly.suffix(1)

            if first == "0", !"123456789".contains(second) {
                return false
            }
            if first == "1", !"012".contains(second) {
                return false
            }
        }

        if digitsOnly.count == 3, string == "0" {
            return false
        }

        if digitsOnly.count == 4 {
            let yearString = String(digitsOnly.suffix(2))
            if yearString.first == "0" {
                return false
            }
        }

        var formattedText = ""
        if limitedText.count <= 2 {
            formattedText = limitedText
        } else {
            let month = limitedText.prefix(2)
            let year = limitedText.suffix(from: limitedText.index(limitedText.startIndex, offsetBy: 2))
            formattedText = "\(month)/\(year)"
        }

        textField.text = formattedText

        // Trigger end-editing callback when fully filled (length 5: "MM/YY")
        if formattedText.count == 5 {
            self.textEditingDidEnd()
        }

        return false
    }
}

// MARK: - CardExpirationDateFieldView + ShimmerableView

extension CardExpirationDateFieldView: ShimmerableView {
    var shimmeringViews: [UIView] {
        [titleLabel, containerView]
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [titleLabel: .automatic]
    }
}

// MARK: - CardExpirationDateFieldView + KeyboardToolbarable

extension CardExpirationDateFieldView: KeyboardToolbarable {
    var firstResponderInput: UITextField {
        textField
    }
}
