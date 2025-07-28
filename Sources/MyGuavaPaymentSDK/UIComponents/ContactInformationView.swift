//
//  ContactInformationView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit
import SnapKit

final class ContactInformationView: ThemedInputContainerView {
    var onSelectPhoneCode: (() -> Void)?
    var onSaveButton: ((_ phoneNumber: String, _ email: String) -> Void)?

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    private let headerContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private let titleСontainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UICustomization.Label.textColor
        label.font = .body2Semibold
        label.text = "Your contact information"
        label.numberOfLines = 0
        return label
    }()

    private let changeInfoButton = Button(
        config: Button.Config(
            type: .text("Change info"),
            state: .enabled,
            scheme: Button.Scheme.secondary,
            size: .small
        )
    )

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UICustomization.Label.secondaryTextColor
        label.font = .body2Regular
        label.text = "To proceed, please provide either your phone number or your email address."
        label.numberOfLines = 0
        return label
    }()

    private let emailСontainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UICustomization.Label.secondaryTextColor
        label.font = .body2Regular
        label.text = "Email: "
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let emailValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UICustomization.Label.secondaryTextColor
        label.font = .body2Regular
        return label
    }()

    private let phoneNumberСontainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let phoneNumberTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UICustomization.Label.secondaryTextColor
        label.font = .body2Regular
        label.text = "Phone number: "
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let phoneNumberValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UICustomization.Label.secondaryTextColor
        label.font = .body2Regular
        return label
    }()

    private let emailFieldView = EmailFieldView()

    private let phoneNumberFieldsСontainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .bottom
        stackView.spacing = 16
        return stackView
    }()

    private let countryCodeSelectFieldView = SelectFieldView()

    private let phoneNumberFieldView = PhoneNumberInputView()

    private let buttonsСontainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .bottom
        stackView.spacing = 16
        return stackView
    }()

    private let cancelButtonView = Button(
        config: Button.Config(
            type: .text("Cancel"),
            state: .enabled,
            scheme: Button.Scheme.ghost,
            size: .large
        )
    )

    private let saveButtonView = Button(
        config: Button.Config(
            type: .text("Save"),
            state: .focused,
            scheme: Button.Scheme.primary,
            size: .large
        )
    )

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    private var payer: Payer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        bindActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UICustomization.Common.backgroundSecondaryColor
        layer.borderWidth = UICustomization.Input.borderWidth
        layer.borderColor = UICustomization.Input.borderColor.cgColor
        layer.cornerRadius = Radius.s
        layer.masksToBounds = true
        isSkeletonable = true

        changeInfoButton.setContentHuggingPriority(.required, for: .horizontal)
        cancelButtonView.setContentHuggingPriority(.required, for: .horizontal)
        saveButtonView.setContentHuggingPriority(.required, for: .horizontal)

        countryCodeSelectFieldView.setTitleText("Phone")

        titleСontainerStackView.addArrangedSubviews(titleLabel, changeInfoButton)

        emailСontainerStackView.addArrangedSubviews(
            emailTitleLabel,
            emailValueLabel
        )

        phoneNumberСontainerStackView.addArrangedSubviews(
            phoneNumberTitleLabel,
            phoneNumberValueLabel
        )

        headerContainerStackView.addArrangedSubviews(
            titleСontainerStackView,
            subtitleLabel,
            emailСontainerStackView,
            phoneNumberСontainerStackView
        )

        phoneNumberFieldsСontainerStackView.addArrangedSubviews(
            countryCodeSelectFieldView,
            phoneNumberFieldView
        )

        buttonsСontainerStackView.addArrangedSubviews(
            UIView(),
            cancelButtonView,
            saveButtonView
        )

        containerStackView.addArrangedSubviews(
            headerContainerStackView,
            emailFieldView,
            phoneNumberFieldsСontainerStackView,
            buttonsСontainerStackView
        )
        addSubview(containerStackView)
    }

    private func setupLayout() {
        containerStackView.snp.makeConstraints {
            $0.directionalEdges.edges.equalToSuperview().inset(16)
        }

        cancelButtonView.snp.makeConstraints {
            $0.width.equalTo(80)
        }

        saveButtonView.snp.makeConstraints {
            $0.width.equalTo(80)
        }
    }

    private func bindActions() {
        countryCodeSelectFieldView.onAction = { [weak self] in
            self?.onSelectPhoneCode?()
        }

        changeInfoButton.setAction { [weak self] in
            self?.setViewState(forChange: true)
        }

        cancelButtonView.setAction { [weak self] in
            self?.setViewState(forChange: false)
        }

        saveButtonView.setAction { [weak self] in
            guard let self else { return }

            setViewState(forChange: false)
            onSaveButton?(phoneNumberFieldView.phoneNumber, emailFieldView.email)
        }
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            emailFieldView.isHidden = true
            phoneNumberFieldsСontainerStackView.isHidden = true
            buttonsСontainerStackView.isHidden = true
            layer.borderWidth = 0
            startShimmering()
        } else {
            setCurrentData(payer)
            layer.borderWidth = 1
            stopShimmering()
        }
    }

    private func setViewState(forChange: Bool) {
        changeInfoButton.isHidden = forChange
        emailСontainerStackView.isHidden = forChange
        phoneNumberСontainerStackView.isHidden = forChange

        emailFieldView.isHidden = !forChange
        phoneNumberFieldsСontainerStackView.isHidden = !forChange
        buttonsСontainerStackView.isHidden = !forChange

        if !forChange {
            phoneNumberFieldView.resignFirstResponder()
            emailFieldView.resignFirstResponder()
        }
    }

    func configureSelectCountry(_ country: CountryResponse) {
        countryCodeSelectFieldView.setIconView(
            .flag(view:
                    UIImageView(image: Icons.Flags.icon(with: country.countryCode))
                 )
        )
        countryCodeSelectFieldView.setInputText(country.phoneCode)
        phoneNumberFieldView.configure(with: country)
    }

    func configureValidEmailField(_ isValid: Bool) {
        emailFieldView.configureValidEmailField(isValid)
    }

    func setCurrentData(_ data: Payer?) {
        payer = data

        let contactEmail = data?.contactEmail ?? data?.maskedContactEmail

        let phone = data?.contactPhone
        let formattedPhone: String? = if let code = phone?.countryCode, let number = phone?.nationalNumber {
            [code, number].joined(separator: " ")
        } else {
            data?.maskedContactPhone?.formatted
        }

        let isNilContactInfo = contactEmail == nil || formattedPhone == nil

        changeInfoButton.isHidden = isNilContactInfo
        emailСontainerStackView.isHidden = isNilContactInfo
        phoneNumberСontainerStackView.isHidden = isNilContactInfo

        emailFieldView.isHidden = !isNilContactInfo
        phoneNumberFieldsСontainerStackView.isHidden = !isNilContactInfo
        buttonsСontainerStackView.isHidden = !isNilContactInfo

        emailValueLabel.text = contactEmail
        phoneNumberValueLabel.text = formattedPhone
    }

    /// Shows shimmer loading
    func showLoading() {
        isLoading = true
    }

    /// Hides shimmer loading
    func hideLoading() {
        isLoading = false
    }
}

// MARK: - ContactInformationView + ShimmerableView

extension ContactInformationView: ShimmerableView {
    var shimmeringViews: [UIView] {
        [self]
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [self: .value(10)]
    }
}
