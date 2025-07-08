//
//  SecurityCodeInputView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 12.06.2025.
//

import UIKit
import SnapKit

final class SecurityCodeInputView: UIView {

    var onEndEditing: ((String) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Security code"
        label.textColor = .input.primaryForeground
        label.font = .body1Regular
        label.isSkeletonable = true
        return label
    }()

    private lazy var cvvInputField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.delegate = self
        textField.placeholder = "CVV"
        textField.keyboardType = .numberPad
        textField.font = .body1Regular
        textField.attributedPlaceholder = NSAttributedString(
            string: "CVV",
            attributes: [
                .foregroundColor: UIColor.foreground.secondary
            ]
        )
        textField.textColor = .input.primaryForeground
        textField.borderStyle = .none
        textField.setLeftPadding(12)
        textField.addTarget(self, action: #selector(textEditingDidEnd), for: .editingDidEnd)
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
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.input.borderRest.cgColor
        view.isSkeletonable = true
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

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .input.dangerForeground
        label.font = .caption1Regular
        label.alpha = 0
        return label
    }()

    private var isShowingError: Bool = false

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
        addSubview(errorLabel)

        containerView.addSubview(contentStack)
        contentStack.addArrangedSubview(cvvInputField)
        contentStack.addArrangedSubview(cardIconImageView)

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(12)
        }

        errorLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(4)
            $0.directionalHorizontalEdges.equalToSuperview()
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12))
        }

        cardIconImageView.snp.makeConstraints {
            $0.width.equalTo(34)
            $0.height.equalTo(32)
        }
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

    private func showError(_ message: String) {
        guard !isShowingError || errorLabel.text != message else { return }
        isShowingError = true

        UIView.animate(withDuration: 0.25) {
            self.containerView.layer.borderColor = UIColor.systemRed.cgColor
            self.errorLabel.text = message
            self.errorLabel.alpha = 1
        }
    }

    private func hideError() {
        guard isShowingError else { return }
        isShowingError = false

        UIView.animate(withDuration: 0.25) {
            self.containerView.layer.borderColor = UIColor.input.borderRest.cgColor
            self.errorLabel.alpha = 0
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

    func getCVV() -> String {
        return cvvInputField.text ?? ""
    }

    func isValidCVV() -> Bool {
        let regex = #"^\d{3,4}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: getCVV())
    }

    func showState(_ state: CardSecurityCodeState) {
        switch state {
        case .normal:
            cvvInputField.isEnabled = true
            hideError()
        case let .error(text):
            cvvInputField.isEnabled = true
            showError(text)
        case .disable:
            cvvInputField.isEnabled = false
        }
    }

    @objc
    private func textEditingDidEnd() {
        onEndEditing?(cvvInputField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension SecurityCodeInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let current = textField.text, let range = Range(range, in: current) else { return false }

        let updated = current.replacingCharacters(in: range, with: string)
        let digits = updated.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)

        if digits.count > 4 { return false }

        textField.text = digits
        return false
    }
}

// MARK: - SecurityCodeInputView + ShimmerableView

extension SecurityCodeInputView: ShimmerableView {
    public var shimmeringViews: [UIView] {
        [titleLabel, containerView]
    }

    public var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [titleLabel: .automatic]
    }
}
