//
//  SearchFieldView.swift
//
//
//  Created by Ignat Chegodaykin on 19.06.2024.
//

import UIKit

final class SearchFieldView: UIView {

    var cancelButtonTapHandler: (() -> Void)?
    var clearButtonTapHandler: (() -> Void)?

    // MARK: - Subviews

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = .spacing400
        return stackView
    }()

    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.search.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let clearIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.smallClose.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let fieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = .spacing200
        stackView.alignment = .center
        stackView.layer.cornerRadius = .radius200
        stackView.layer.borderWidth = 1
        stackView.layoutMargins = .init(
            top: .spacing300,
            left: .spacing300,
            bottom: .spacing300,
            right: .spacing300
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stackView
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.returnKeyType = UIReturnKeyType.search
        textField.autocorrectionType = .no
        textField.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return textField
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .right
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.isHidden = true
        return button
    }()

    // MARK: - Properties

    private var style: Style
    weak var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }
    var placeholder: String = "" {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: style.titleFont,
                    .foregroundColor: style.tintColor
                ]
            )
        }
    }

    var valueChanged: ((String) -> Void)?

    // MARK: - Init

    init(style: Style = StockStyle()) {
        self.style = style

        super.init(frame: .zero)

        setupView()
        setupLayout()
        applyStyle()
    }

    override init(frame: CGRect) {
        style = StockStyle()

        super.init(frame: .zero)

        setupView()
        setupLayout()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupView() {
        textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(didBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)

        clearIconImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didClearButtonTapped)
            )
        )

        addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapped)
            )
        )

        cancelButton.addTarget(self, action: #selector(didCancelButtonTapped), for: .touchUpInside)

        fieldStackView.addArrangedSubviews([
            searchIconImageView,
            textField,
            clearIconImageView
        ])
        containerStackView.addArrangedSubviews([
            fieldStackView,
            cancelButton
        ])
        addSubview(containerStackView)
    }

    // MARK: - Layout

    private func setupLayout() {
        containerStackView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
        searchIconImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        clearIconImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
    }

    private func updateButtonLayout(isHidden: Bool) {
        // It is necessary to prevent the stackview from breaking.
        guard cancelButton.isHidden != isHidden else {
            return
        }

        UIView.animate(
            withDuration: 0.33,
            delay: 0,
            options: .beginFromCurrentState
        ) { [weak self] in
            self?.cancelButton.alpha = !isHidden ? 1 : 0
            self?.cancelButton.isHidden = isHidden
            self?.layoutIfNeeded()
        }
    }

    private func updateViewWithStyle(_ style: SearchFieldView.Style) {
        backgroundColor = .clear

        fieldStackView.layer.borderColor = style.borderColor.cgColor

        searchIconImageView.tintColor = style.foregroundColor
        clearIconImageView.tintColor = style.foregroundColor
        fieldStackView.backgroundColor = style.backgroundColor
        textField.tintColor = style.cursorColor
        textField.textColor = style.foregroundColor
        textField.font = style.titleFont

        cancelButton.setTitleColor(style.foregroundColor, for: .normal)
        cancelButton.titleLabel?.font = style.titleFont

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: style.titleFont,
                .foregroundColor: style.tintColor
            ]
        )
    }

    // MARK: - methods

    func setValue(_ value: String?) {
        textField.text = value
        clearIconImageView.isHidden = value == nil
    }

    func becomeResponder() {
        textField.becomeFirstResponder()
    }

    func resignResponder() {
        textField.resignFirstResponder()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        applyStyle()
    }

    func applyStyle() {
        let style = StockStyle.getStyle()
        updateViewWithStyle(style)
    }

    // MARK: - Actions

    @objc private func didClearButtonTapped() {
        textField.becomeFirstResponder()
        textField.text = ""

        guard let clearButtonTapHandler else {
            textFieldValueChanged(textField)
            return
        }
        clearButtonTapHandler()
    }

    @objc private func didTapped() {
        textField.becomeFirstResponder()
    }

    @objc private func didCancelButtonTapped() {
        textField.text = ""

        defer {
            didEndEditing(textField)
        }

        guard let cancelButtonTapHandler else {
            textFieldValueChanged(textField)
            return
        }
        cancelButtonTapHandler()
    }

    @objc private func textFieldValueChanged(_ textField: UITextField) {
        guard let value = textField.text else {
            return
        }

        valueChanged?(value)
        clearIconImageView.isHidden = value.isEmpty
    }

    @objc private func didBeginEditing(_ textField: UITextField) {
        updateButtonLayout(isHidden: false)
        fieldStackView.layer.borderColor = style.activeBorderColor.cgColor
    }

    @objc private func didEndEditing(_ textField: UITextField) {
        fieldStackView.layer.borderColor = style.borderColor.cgColor
        guard let value = textField.text else { return }

        clearIconImageView.isHidden = value.isEmpty
        updateButtonLayout(isHidden: true)
        textField.resignFirstResponder()
    }
}
