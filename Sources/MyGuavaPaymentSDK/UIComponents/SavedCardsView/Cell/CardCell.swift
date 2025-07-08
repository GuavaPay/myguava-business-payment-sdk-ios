//
//  CardCell.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 20.06.2025.
//

import UIKit
import SnapKit

final class CardCell: UITableViewCell {

    var onEditButtonTapped: (() -> Void)?
    var onDeleteButtonTapped: (() -> Void)?

    var isEdit: Bool = false {
        didSet {
            updateEditLayout(isHidden: isEdit)
        }
    }

    override var isSelected: Bool {
        didSet {
            updateSelection(isSelected)
        }
    }

    private var isEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = isEnabled

            paymentIconContainer.layer.opacity = isEnabled ? 1.0 : 0.6
            radioButton.isEnabled = isEnabled

            moreButton.layer.borderWidth = isEnabled ? 1 : 0
            moreButton.isEnabled = isEnabled
            securityCodeInputIsHidden = !isEnabled
        }
    }

    private var securityCodeInputIsHidden: Bool = true {
        didSet {
            guard oldValue != securityCodeInputIsHidden else { return }
            securityCodeInputView.isHidden = securityCodeInputIsHidden
            securityCodeInputView.alpha = securityCodeInputIsHidden ? 0.5 : 1
        }
    }

    private let mainContainerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let cardInfoContainerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.layer.cornerRadius = 8
        stackView.layer.masksToBounds = true
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.border.primary.cgColor
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 12)
        return stackView
    }()

    private let paymentIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .background.primary
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.border.primary.cgColor
        return view
    }()

    private let paymentIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let cardVluesContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = .body2Regular
        label.textColor = .foreground.onAccent
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let cardNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1Regular
        label.textColor = .foreground.onAccentSecondary
        return label
    }()

    private let radioButton = RadioButtonView()

    private let securityCodeInputView: CVVCodeInputView = {
        let view = CVVCodeInputView()
        view.isHidden = true
        return view
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.more, for: .normal)
        button.backgroundColor = .background.secondary
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.border.primary.cgColor
        button.imageView?.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return button
    }()

    private let trashButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.trash.withRenderingMode(.alwaysTemplate), for: .normal)
        button.backgroundColor = .button.dangerBackgroundRest
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        button.tintColor = .background.primary
        button.isHidden = true
        return button
    }()

    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.pencil, for: .normal)
        button.backgroundColor = .background.primary
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.foreground.onAccent.cgColor
        button.imageView?.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        button.isHidden = true
        return button
    }()

    /// Flag responsible for enabling the shimmer display
    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        hideLoading()
    }

    override func traitCollectionDidChange(_: UITraitCollection?) {
        if isLoading {
            showShimmerIfNeeded()
        }
    }

    private func setupUI() {
        backgroundColor = .background.primary
        selectionStyle = .none
        radioButton.isUserInteractionEnabled = false
        cardInfoContainerStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        moreButton.setContentHuggingPriority(.required, for: .horizontal)
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(didTapTrashButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)

        paymentIconContainer.addSubview(paymentIconImageView)

        cardVluesContainerStackView.addArrangedSubviews(
            cardNameLabel,
            cardNumberLabel
        )

        cardInfoContainerStack.addArrangedSubviews(
            paymentIconContainer,
            cardVluesContainerStackView,
            radioButton
        )

        mainContainerStack.addArrangedSubviews(
            cardInfoContainerStack,
            securityCodeInputView,
            editButton,
            trashButton,
            moreButton
        )

        contentView.addSubviews(mainContainerStack)

        mainContainerStack.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(6)
            $0.directionalHorizontalEdges.equalToSuperview()
        }

        paymentIconContainer.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 46, height: 32))
        }

        paymentIconImageView.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().inset(6)
            $0.center.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(6)
        }

        radioButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }

        securityCodeInputView.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(101)
        }

        editButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 40, height: 48))
        }

        trashButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 40, height: 48))
        }

        moreButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 40, height: 48))
        }
    }

    private func updateSelection(_ isSelected: Bool) {
        radioButton.onChecked = isSelected
        if !isEdit {
                securityCodeInputIsHidden = !isSelected
        } else {
            securityCodeInputIsHidden = true
        }

        cardInfoContainerStack.layer.borderWidth = isSelected ? 2 : 1
        cardInfoContainerStack.layer.borderColor = isSelected
        ? UIColor.input.borderFocused.cgColor
        : UIColor.border.primary.cgColor
      }

    private func updateEditLayout(isHidden: Bool) {
        guard moreButton.isEnabled else {
            return
        }

        moreButton.setImage(isHidden ? Icons.smallClose : Icons.more, for: .normal)

        UIView.animate(
            withDuration: 0.33,
            delay: 0,
            options: .beginFromCurrentState
        ) { [weak self] in
            guard let self else { return }
            if radioButton.onChecked {
                securityCodeInputIsHidden = isHidden
            }

            editButton.alpha = isHidden ? 1 : 0
            editButton.isHidden = !isHidden

            trashButton.alpha = isHidden ? 1 : 0
            trashButton.isHidden = !isHidden

            layoutIfNeeded()
        }
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            isUserInteractionEnabled = false
            mainContainerStack.layer.cornerRadius = 10
            startShimmering()
        } else {
            isUserInteractionEnabled = true
            mainContainerStack.layer.cornerRadius = 0
            stopShimmering()
        }
    }

    @objc private func didTapMoreButton() {
        isEdit.toggle()
    }

    @objc private func didTapTrashButton() {
        onDeleteButtonTapped?()
    }

    @objc private func didTapEditButton() {
        onEditButtonTapped?()
    }

    func configure(with viewModel: Binding) {
        paymentIconImageView.image = viewModel.cardData?.cardScheme.icon
        cardNameLabel.text = viewModel.cardData?.cardScheme.rawValue
        cardNumberLabel.text = viewModel.cardData?.maskedPan
        securityCodeInputView.maxLength = viewModel.cardData?.cardScheme.cvvLength ?? 3
        isEnabled = viewModel.isEnabled
    }
}

// MARK: - Redesign.CryptoNewsCell + ShimmerableCell

extension CardCell: ShimmerableCell {
    var shimmeringViews: [UIView] {
        [mainContainerStack]
    }

    func showLoading() {
        isLoading = true
    }

    func hideLoading() {
        isLoading = false
    }
}
