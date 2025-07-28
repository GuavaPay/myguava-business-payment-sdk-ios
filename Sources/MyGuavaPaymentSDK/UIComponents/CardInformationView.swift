//
//  CardInformationView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 12.06.2025.
//

import UIKit
import SnapKit
import Kingfisher

final class CardInformationView: UIView {

    enum Field {
        case cardNumber(String)
        case expirationDate(month: String, year: String)
        case securityCode(Int)
        case cardName(String)
        case cardHolderName(String)
    }

    let cardNumberView = CardNumberFieldView()
    let expirationView = CardExpirationDateFieldView()
    let securityCodeView = SecurityCodeInputView()
    let cardHolderNameFieldView = CardholderNameFieldView()

    var onSaveCardTapped: ((Bool) -> Void)?
    var onScanButtonTapped: (() -> Void)?
    var onFieldEndEditing: ((Field) -> Void)?
    var onNewCardNameTextChange: ((String) -> Void)?

    private let checkboxEmptyImage = Icons.checkboxEmpty.withRenderingMode(.alwaysTemplate)

    private lazy var checkboxImageView: UIImageView = {
        let imageView = UIImageView(image: checkboxEmptyImage)
        imageView.tintColor = UICustomization.Input.textColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var saveCardTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .footnoteRegular
        label.textColor = .foreground.onAccent
        label.text = "Save the card for future payments"
        return label
    }()

    private let bottomInputsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var saveCardStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [checkboxImageView, saveCardTitleLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = true
        stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSaveTap)))
        return stack
    }()

    private let saveCardContainer = UIView()

    private lazy var cardNameFieldView: CardNameFieldView = {
        let view = CardNameFieldView()
        view.alpha = 0
        return view
    }()

    private let bottomSpacer = UIView()

    private let bottomSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let cardContainerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private var cardNameFieldHeightConstraint: Constraint?
    private var bottomSpacerHeightConstraint: Constraint?
    private var isAdditionalViewVisible = false


    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupLayout()
        bindActions()
        showShimmerIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        showShimmerIfNeeded()
    }

    private func addSubviews() {
        addSubview(cardContainerStack)

        saveCardContainer.isSkeletonable = true

        bottomInputsStack.addArrangedSubview(expirationView)
        bottomInputsStack.addArrangedSubview(securityCodeView)

        saveCardContainer.addSubview(saveCardStack)

        bottomSectionStack.addArrangedSubview(bottomInputsStack)
        bottomSectionStack.addArrangedSubview(cardHolderNameFieldView)
        bottomSectionStack.setCustomSpacing(16, after: cardHolderNameFieldView)
        bottomSectionStack.addArrangedSubview(saveCardContainer)
        bottomSectionStack.setCustomSpacing(16, after: saveCardContainer)
        bottomSectionStack.addArrangedSubview(cardNameFieldView)

        cardContainerStack.addArrangedSubview(cardNumberView)
        cardContainerStack.setCustomSpacing(16, after: cardNumberView)
        cardContainerStack.addArrangedSubview(bottomSectionStack)
        
    }

    private func setupLayout() {
        cardContainerStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        saveCardStack.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }

        cardNameFieldView.snp.makeConstraints {
            cardNameFieldHeightConstraint = $0.height.equalTo(0).constraint
        }

        bottomSpacer.snp.makeConstraints {
            bottomSpacerHeightConstraint = $0.height.equalTo(0).constraint
        }
    }
    
    func hideCardholderInput() {
        cardHolderNameFieldView.isHidden = true
    }
    
    func setSaveCardCheckboxVisible(_ isVisible: Bool) {
        if isVisible {
            if bottomSectionStack.arrangedSubviews.contains(saveCardContainer) == false {
                bottomSectionStack.insertArrangedSubview(saveCardContainer, at: 1)
            }
            saveCardStack.isHidden = false
            bottomSectionStack.setCustomSpacing(20, after: bottomInputsStack)
        } else {
            saveCardStack.isHidden = true
            bottomSectionStack.removeArrangedSubview(saveCardContainer)
            saveCardContainer.removeFromSuperview()
            bottomSectionStack.setCustomSpacing(8, after: bottomInputsStack)
        }
    }

    private func bindActions() {
        cardNumberView.onScanButtonTapped = { [weak self] in
            self?.onScanButtonTapped?()
        }

        cardNumberView.onEndEditing = { [weak self] digits in
            self?.onFieldEndEditing?(.cardNumber(digits))
        }

        cardNameFieldView.onTextChanged = { [weak self] text in
            self?.onFieldEndEditing?(.cardName(text))
        }

        expirationView.onEndEditing = { [weak self] month, year in
            self?.onFieldEndEditing?(.expirationDate(month: month, year: year))
        }

        securityCodeView.onEndEditing = { [weak self] digits in
            guard let code = Int(digits) else { return }
            self?.onFieldEndEditing?(.securityCode(code))
        }
        
        cardHolderNameFieldView.onTextChanged = { [weak self] text in
            self?.onFieldEndEditing?(.cardHolderName(text))
        }
    }

    @objc
    private func handleSaveTap() {
        if isAdditionalViewVisible {
            cardNameFieldHeightConstraint?.update(offset: 0)
            bottomSpacerHeightConstraint?.update(offset: 0)
            checkboxImageView.image = checkboxEmptyImage
        } else {
            cardNameFieldHeightConstraint?.update(offset: 74)
            bottomSpacerHeightConstraint?.update(offset: 24)
            checkboxImageView.image = Icons.checkboxSelected
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.cardNameFieldView.alpha = self.isAdditionalViewVisible ? 0 : 1
            self.layoutIfNeeded()

            if let sheetVC = self.parentViewController as? PaymentViewController {
                sheetVC.updatePreferredHeight()
            }
        })
        isAdditionalViewVisible.toggle()
        onSaveCardTapped?(isAdditionalViewVisible)
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            cardNumberView.showLoading()
            expirationView.showLoading()
            securityCodeView.showLoading()

            cardNameFieldView.showLoading()
            startShimmering()
            cardHolderNameFieldView.showLoading()
        } else {
            cardNumberView.hideLoading()
            expirationView.hideLoading()
            securityCodeView.hideLoading()
            cardHolderNameFieldView.hideLoading()

            cardNameFieldView.hideLoading()
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
    
    func disable() {
        expirationView.disable()
        cardHolderNameFieldView.disable()
        cardNumberView.showState(.disable)
        securityCodeView.showState(.disable)
        setSaveCardCheckboxVisible(false)
    }
}

// MARK: - CardInformationView + ShimmerableView

extension CardInformationView: ShimmerableView {
    var shimmeringViews: [UIView] {
        [saveCardContainer]
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [saveCardContainer: .automatic]
    }
}


// MARK: - Helpers

fileprivate extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
    }
}
