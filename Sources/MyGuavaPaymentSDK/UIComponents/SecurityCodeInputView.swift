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
        label.textColor = UICustomization.Label.textColor
        label.font = .body1Regular
        label.isSkeletonable = true
        return label
    }()

    private lazy var cvvInputField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "CVV"
        textField.keyboardType = .numberPad
        textField.font = .body1Regular
        textField.attributedPlaceholder = NSAttributedString(
            string: "CVV",
            attributes: [
                .foregroundColor: UICustomization.Input.placeholderTextColor
            ]
        )
        textField.addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)
        textField.addKeyboardDoneToToolbar()
        textField.textColor = UICustomization.Input.textColor
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

    private var actualCVV: String = ""
    private var resolvedCodeLength: Int?
    private var maskTimer: Timer?

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

    /// Shows shimmer loading
    func showLoading() {
        isLoading = true
    }

    /// Hides shimmer loading
    func hideLoading() {
        isLoading = false
    }

    func getCVV() -> String {
        return actualCVV
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

    func setCodeLength(_ length: Int) {
        resolvedCodeLength = length
    }
}

// MARK: - Private

private extension SecurityCodeInputView {
    func setupLayout() {
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

    func showShimmerIfNeeded() {
        if isLoading {
            containerView.layer.borderWidth = 0
            startShimmering()
        } else {
            containerView.layer.borderWidth = 1
            stopShimmering()
        }
    }

    func showError(_ message: String) {
        guard !isShowingError || errorLabel.text != message else { return }
        isShowingError = true

        UIView.animate(withDuration: 0.25) {
            self.containerView.layer.borderColor = UIColor.systemRed.cgColor
            self.errorLabel.text = message
            self.errorLabel.alpha = 1
        }
    }

    func hideError() {
        guard isShowingError else { return }
        isShowingError = false

        UIView.animate(withDuration: 0.25) {
            self.containerView.layer.borderColor = UIColor.input.borderRest.cgColor
            self.errorLabel.alpha = 0
        }
    }

    func showMaskedCVVWithLastDigitVisible() {
        maskTimer?.invalidate()

        let masked = String(repeating: "*", count: max(0, actualCVV.count - 1))
        let display = masked + actualCVV.suffix(1)
        cvvInputField.text = display

        // Через 0.5 сек скрываем последнюю цифру
        maskTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.cvvInputField.text = String(repeating: "*", count: self.actualCVV.count)
        }
    }

    @objc
    func handleEditingDidEnd() {
        onEndEditing?(actualCVV)
    }
}

// MARK: - UITextFieldDelegate

extension SecurityCodeInputView: UITextFieldDelegate {
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

        // Trigger end-editing callback when fully filled (3 or 4 digits)
        // Resolved by card scheme from `/resolve` endpoint
        if let resolvedCodeLength, newValue.count == resolvedCodeLength {
            self.handleEditingDidEnd()
        }

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onEndEditing?(actualCVV)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - SecurityCodeInputView + ShimmerableView

extension SecurityCodeInputView: ShimmerableView {
    var shimmeringViews: [UIView] {
        [titleLabel, containerView]
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [titleLabel: .automatic]
    }
}

// MARK: - SecurityCodeInputView + KeyboardToolbarable

extension SecurityCodeInputView: KeyboardToolbarable {
    var firstResponderInput: UITextField {
        cvvInputField
    }
}
