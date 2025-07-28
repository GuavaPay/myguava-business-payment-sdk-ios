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
        textField.addKeyboardDoneToToolbar()
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
        guard let text = textField.text, let range = Range(range, in: text) else { return false }
        let newText = text.replacingCharacters(in: range, with: string)
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "\\D", with: "", options: .regularExpression)

        let trimmed = String(newText.prefix(4))
        var result = ""

        if trimmed.count >= 2 {
            let index = trimmed.index(trimmed.startIndex, offsetBy: 2)
            result = String(trimmed[..<index]) + "/" + String(trimmed[index...])
        } else {
            result = trimmed
        }

        textField.text = result
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
