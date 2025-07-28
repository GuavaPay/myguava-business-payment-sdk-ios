//
//  CardNameFieldView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 13.06.2025.
//

import UIKit
import SnapKit

final class CardNameFieldView: UIView {

    var onTextChanged: ((String) -> Void)?

    private let inputField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.placeholder = "Name your card"
        textField.font = .body1Regular
        textField.textColor = UICustomization.Input.textColor
        textField.backgroundColor = UICustomization.Input.backgroundColor
        textField.layer.cornerRadius = UICustomization.Input.cornerRadius
        textField.layer.masksToBounds = false
        textField.layer.borderWidth = UICustomization.Input.borderWidth
        textField.layer.borderColor = UICustomization.Input.borderColor.cgColor
        textField.setLeftPadding(10)
        textField.autocorrectionType = .no
        textField.isSkeletonable = true
        return textField
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Card name"
        label.textColor = UICustomization.Label.textColor
        label.font = .body1Regular
        label.isSkeletonable = true
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        inputField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        showShimmerIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        showShimmerIfNeeded()
    }

    private func setupLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(inputField)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        inputField.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            inputField.layer.borderWidth = 0
            startShimmering()
        } else {
            inputField.layer.borderWidth = 1
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
    private func textFieldDidChange(_ textField: UITextField) {
        onTextChanged?(textField.text ?? "")
    }
}

// MARK: - CardNameFieldView + ShimmerableView

extension CardNameFieldView: ShimmerableView {
    var shimmeringViews: [UIView] {
        [titleLabel, inputField]
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [titleLabel: .automatic]
    }
}
