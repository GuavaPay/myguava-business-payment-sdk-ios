//
//  SelectFieldView.swift
//  GuavaDesign
//
//  Created by Ignat Chegodaykin on 15.10.2024.
//

import UIKit

final class SelectFieldView: UIView {

    private let mainContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private let textFieldContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()

    // MARK: - Main left icon

    private let iconContainerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.isHidden = true
        return view
    }()

    // MARK: - Drop down arrow

    private let dropDownArrowContainerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    private let dropDownArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Icons.chevronDown
        return imageView
    }()

    // MARK: - TextField with placeholder

    private let textFieldWithHelperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .equalSpacing
        return stackView
    }()

    let textField: UITextField = {
        let textField = UITextField()
        textField.addKeyboardDoneToToolbar()
        textField.borderStyle = .none
        textField.isEnabled = false
        return textField
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    // MARK: - Bottom messages

    private let bottomLeftLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let bottomRightLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        return stackView
    }()

    // MARK: - Properties

    weak var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }

    /// Affects the presence of the transparency effect of the main icon for the state disable
    private var handelDisableState: Bool = true

    private var style: Style {
        Self.StockStyle.getStyle(
            state ?? .enabled
        )
    }
    
    /// Enables manual text input into the selector. Disabled by default.
    var isEnabled: Bool = false {
        didSet {
            textField.isEnabled = isEnabled
        }
    }

    /// Allows you to set the current state for the selector
    var state: State? {
        didSet {
            applyStyle()
        }
    }
    
    /// Allows you to set the message text for the left part under the selector field
    var bottomLeftText: String? {
        didSet {
            bottomLeftLabel.text = bottomLeftText
            applyStyle()
        }
    }

    /// Allows you to set the message text for the right part under the selector field
    var bottomRightText: String? {
        didSet {
            bottomRightLabel.text = bottomRightText
            applyStyle()
        }
    }
    
    /// Short circuit triggered by textfield value change
    var valueChanged: ((String) -> Void)?
    
    /// Callback called when the component is clicked
    var onAction: (() -> Void)?

    private var placeholderText: String?

    // MARK: - Init
    
    /// Init
    /// - Parameters:
    ///   - state: Allows you to set the current state for the selector
    ///   - helperText: Allows you to set the text of the message that moves up when typing
    ///   - placeholderText: Allows you to set the placeholder text
    ///   - bottomLeftText: Allows you to set the message text for the left part under the selector field
    ///   - bottomRightText: Allows you to set the message text for the right part under the selector field
    init(
        state: State = .enabled,
        placeholderText: String? = nil,
        bottomLeftText: String? = nil,
        bottomRightText: String? = nil
    ) {
        self.state = state
        self.placeholderText = placeholderText
        self.bottomLeftText = bottomLeftText
        self.bottomRightText = bottomRightText

        super.init(frame: .zero)

        setupView()
        setupLayout()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        applyStyle()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: style.height)
    }
    
    /// Sets dropDown Image
    func setDropDownImage(_ image: UIImage?) {
        dropDownArrowImageView.image = image
        applyStyle()
    }

    /// Allows you to set the primary icon on the left side of the selector
    /// - Parameter view: Represents an enumeration for selecting the type of view to be embedded.
    func setIconView(_ view: TypeIconView) {
        iconContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }

        if case .none = view {
            textFieldContainerStackView.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
            iconContainerView.isHidden = true
            return
        }



        if let viewForEmbed = view.getViewForEmbed(),
           let (size, padding, handelDisableState) = view.getLayoutSettings() {
            iconContainerView.addSubview(viewForEmbed)

            self.handelDisableState = handelDisableState

            if case .flag = view {
                viewForEmbed.layer.cornerRadius = size.height / 2
                viewForEmbed.layer.masksToBounds = true
            } else {
                viewForEmbed.layer.cornerRadius = .none
                viewForEmbed.layer.masksToBounds = false
            }

            viewForEmbed.snp.makeConstraints {
                $0.size.equalTo(size)
                $0.directionalEdges.equalToSuperview().inset(padding)
            }
            
            textFieldContainerStackView.layoutMargins = .init(top: 12, left: 8, bottom: 12, right: 16)
            iconContainerView.isHidden = false
        }
    }
    
    /// Allows you to set the placeholder text
    func setPlaceholderText(_ text: String) {
        placeholderLabel.text = text
    }
    
    /// Allows you to set the text of the title field
    func setTitleText(_ text: String) {
        titleLabel.text = text
    }
    
    /// Allows you to set the base text for the selector
    func setInputText(_ text: String) {
        textField.text = text
    }

    // MARK: - Private methods

    private func setupView() {
        placeholderLabel.text = placeholderText
        bottomLeftLabel.text = bottomLeftText
        bottomRightLabel.text = bottomRightText

        textField.addTarget(
            self,
            action: #selector(textFieldValueChanged(_:)),
            for: .editingChanged
        )
        dropDownArrowImageView.image = Icons.chevronDown.withRenderingMode(.alwaysTemplate)

        textField.font = style.inputTextFont
        titleLabel.font = style.titleTextFont
        placeholderLabel.font = style.placeholderTextFont
        bottomLeftLabel.font = style.bottomTextFont
        bottomRightLabel.font = style.bottomTextFont

        textFieldWithHelperStackView.addArrangedSubviews([
            textField
        ])

        dropDownArrowContainerView.addSubview(dropDownArrowImageView)

        textFieldContainerStackView.addArrangedSubviews([
            iconContainerView,
            textFieldWithHelperStackView,
            dropDownArrowContainerView
        ])

        bottomStackView.addArrangedSubviews([
            bottomLeftLabel,
            bottomRightLabel
        ])

        mainContainerStackView.addArrangedSubviews([
            titleLabel,
            textFieldContainerStackView,
            bottomStackView
        ])

        addSubviews([
            mainContainerStackView,
            placeholderLabel
        ])
    }

    private func setupLayout() {
        mainContainerStackView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints {
            $0.size.greaterThanOrEqualTo(24)
        }

        textField.snp.makeConstraints {
            $0.height.equalTo(24)
        }

        dropDownArrowImageView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
            $0.size.equalTo(24)
        }

        placeholderLabel.snp.makeConstraints {
            $0.directionalEdges.equalTo(textField)
        }
    }

    private func applyStyle() {
        textFieldContainerStackView.layer.cornerRadius = style.cornerRadius
        textFieldContainerStackView.clipsToBounds = true
        textFieldContainerStackView.layer.borderWidth = style.borderWidth
        textFieldContainerStackView.layer.borderColor = style.borderColor.resolvedCGColor(traitCollection)
        textFieldContainerStackView.backgroundColor = style.backgroundColor

        textField.textColor = style.textColor
        textField.tintColor = style.tintColor
        placeholderLabel.textColor = style.placeholderTextColor
        titleLabel.textColor = style.titleTextColor

        bottomLeftLabel.textColor = style.bottomTextColor
        bottomRightLabel.textColor = style.bottomTextColor
        dropDownArrowContainerView.isHidden = (state == .blocked) || (state == .blockedLoading) || (dropDownArrowImageView.image == nil)

        bottomStackView.isHidden = (bottomLeftText == nil) && (bottomRightText == nil)

        dropDownArrowImageView.tintColor = state == .disabled ? .foreground.onAccent : .foreground.onAccent

        switch state {
        case .disabled, .blocked, .blockedLoading:
            iconContainerView.layer.opacity = handelDisableState ? 0.5 : 1
        default:
            iconContainerView.layer.opacity = 1
        }
    }

    private func accessoryView(
        accessory: UIView,
        padding: UIEdgeInsets
    ) -> UIView {
        let view = UIView()
        view.addSubview(accessory)

        view.setContentHuggingPriority(.required, for: .horizontal)
        accessory.setContentHuggingPriority(.required, for: .horizontal)

        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        accessory.setContentCompressionResistancePriority(.required, for: .horizontal)

        accessory.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.directionalEdges.equalToSuperview().inset(padding)
        }

        return view
    }

    // MARK: - Actions

    @objc
    private func textFieldValueChanged(_ textField: UITextField) {
        guard let value = textField.text else {
            return
        }

        valueChanged?(value)
    }
}

extension SelectFieldView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard state != .disabled
                && state != .loading
                && state != .blocked
                && state != .blockedLoading
                && state != .error else {
            return
        }
        state = .pressed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard state != .disabled
                && state != .loading
                && state != .blocked
                && state != .blockedLoading else {
            return
        }
        if state == .error {
            state = .error
        } else {
            state = .enabled
        }
        onAction?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard state != .disabled
                && state != .loading
                && state != .blocked
                && state != .blockedLoading else {
            return
        }
        if state == .error {
            state = .error
        } else {
            state = .enabled
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard state != .disabled
                && state != .loading
                && state != .blocked
                && state != .blockedLoading else {
            return
        }
        if state == .error {
            state = .error
        } else {
            state = .enabled
        }
    }
}

// MARK: - TypeIconView

extension SelectFieldView {
    enum TypeIconView {
        case flag(view: UIView)
        case card(view: UIView)
        case custom(view: UIView, size: CGSize, padding: UIEdgeInsets, handelDisableState: Bool)
        case none

        func getLayoutSettings() -> (CGSize, UIEdgeInsets, Bool)? {
            switch self {
            case .flag:
                return (
                    CGSize(width: 24, height: 24),
                    .init(top: 0, left: 8, bottom: 0, right: 4),
                    true
                )
            case .card:
                return (
                    CGSize(width: 24, height: 24),
                    .init(top: 0, left: 4, bottom: 0, right: 4),
                    false
                )
            case let .custom(_, size, padding, handelDisableState):
                return (size, padding, handelDisableState)
            case .none:
                return nil
            }
        }

        func getViewForEmbed() -> UIView? {
            switch self {
            case .flag(let view):
                return view
            case .card(let view):
                return view
            case .custom(let view, _, _, _):
                return view
            case .none:
                return nil
            }
        }
    }
}
