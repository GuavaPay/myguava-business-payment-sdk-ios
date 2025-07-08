//
//  CardNumberFieldView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 13.06.2025.
//

import UIKit
import SnapKit

final class CardNumberFieldView: UIView {

    // MARK: - UI Elements

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.input.borderRest.cgColor
        view.isSkeletonable = true
        return view
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: "0000 0000 0000 0000",
            attributes: [
                .foregroundColor: UIColor.foreground.secondary
            ]
        )
        textField.keyboardType = .numberPad
        textField.font = .body1Regular
        textField.textColor = .input.primaryForeground
        textField.setLeftPadding(10)
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(textEditingDidEnd), for: .editingDidEnd)
        return textField
    }()

    private let cardScanImageView: UIImageView = {
        let imageView = UIImageView(image: Icons.cardScan)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        return imageView
    }()

    private let creditCardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(hex: "#EFEFF0").cgColor
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Card number"
        label.font = .body1Regular
        label.textColor = .input.primaryForeground
        label.isSkeletonable = true
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .input.dangerForeground
        label.font = .caption1Regular
        label.alpha = 0
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private var isShowingError: Bool = false

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    // MARK: - Logic

    private let binDebouncer = PollingDebouncer(interval: 0.3)

    var onChangeDigits: ((String) -> Void)?
    var onEndEditing: ((String) -> Void)?
    var onScanButtonTapped: (() -> Void)?
    
    private var isCardRecognized: Bool = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        setupLayout()
        showShimmerIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        showShimmerIfNeeded()
    }

    func showState(_ state: CardNumberState) {
        switch state {
        case let .normal(viewModel):
            creditCardImageView.isHidden = false
            creditCardImageView.image = viewModel.image
            isCardRecognized = true
            hideError()
        case let .error(text):
            creditCardImageView.isHidden = true
            isCardRecognized = false
            showError(text)
        case .disable:
            textField.isEnabled = false
            creditCardImageView.isHidden = true
            isCardRecognized = false
        }
        binDebouncer.stop()
    }

    func setCardNumber(_ number: String) {
        textField.text = formatCardNumber(number)
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
    public func showLoading() {
        isLoading = true
    }

    /// Hides shimmer loading
    public func hideLoading() {
        isLoading = false
    }
}

// MARK: - Private

private extension CardNumberFieldView {
    func configureViews() {
        let scanGesture = UITapGestureRecognizer(target: self, action: #selector(handleScanTap))
        cardScanImageView.addGestureRecognizer(scanGesture)

        addSubview(stackView)
        stackView.addArrangedSubviews(titleLabel, containerView, errorLabel)
        containerView.addSubviews(textField, cardScanImageView, creditCardImageView)
    }

    func setupLayout() {
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        containerView.snp.makeConstraints { $0.height.equalTo(48) }

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(cardScanImageView.snp.leading).offset(-12)
        }

        cardScanImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(20)
        }

        creditCardImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.equalTo(34)
            $0.height.equalTo(24)
        }
    }

    @objc
    func handleScanTap() {
        onScanButtonTapped?()
    }

    @objc
    func textDidChange() {
        let rawText = textField.text ?? ""
        let digits = rawText.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        let formatted = formatCardNumber(digits)

        if textField.text != formatted {
            textField.text = formatted
        }
        
        if digits.isEmpty {
            creditCardImageView.isHidden = true
            isCardRecognized = false
        } else {
            creditCardImageView.isHidden = !isCardRecognized
        }
        
        if digits.count >= 6 {
            binDebouncer.start { [weak self] in
                self?.onChangeDigits?(digits)
                self?.binDebouncer.stop()
            }
        } else {
            binDebouncer.stop()
            hideError()
        }
    }

    @objc
    func textEditingDidEnd() {
        let rawText = textField.text ?? ""
        let digits = rawText.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        onEndEditing?(digits)
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

    func formatCardNumber(_ digits: String) -> String {
        return stride(from: 0, to: digits.count, by: 4).map {
            let start = digits.index(digits.startIndex, offsetBy: $0)
            let end = digits.index(start, offsetBy: 4, limitedBy: digits.endIndex) ?? digits.endIndex
            return String(digits[start..<end])
        }.joined(separator: " ")
    }
}

// MARK: - UITextFieldDelegate

extension CardNumberFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        let digits = updatedText.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        textField.text = formatCardNumber(String(digits.prefix(19)))
        textDidChange()
        return false
    }
}

// MARK: - CardNameFieldView + ShimmerableView

extension CardNumberFieldView: ShimmerableView {
    public var shimmeringViews: [UIView] {
        [titleLabel, containerView]
    }

    public var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [titleLabel: .automatic]
    }
}
