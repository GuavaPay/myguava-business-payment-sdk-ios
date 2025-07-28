//
//  InputView.swift
//
//
//  Created by Mikhail Kirillov on 14/6/24.
//

import UIKit
import SnapKit

final class PlaceholderInputField: UIView {
    private let textFieldContainer = UIView()

    let textField: DelegatingTextField = {
        let textField = DelegatingTextField()
        textField.borderStyle = .none
        return textField
    }()

    lazy var helperLabel: UILabel = {
        let label = UILabel()
        label.text = "Label"
        return label
    }()

    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Placeholder"
        return label
    }()

    let leftAccessoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = .spacing100
        stack.setContentHuggingPriority(.required, for: .horizontal)
        return stack
    }()

    private let currencyLabel = UILabel()

    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0
        stack.distribution = .equalSpacing
        return stack
    }()

    private var currencyLeading: Constraint?
    private var textFieldTrailing: Constraint?
    private var textFieldLeading: Constraint?

    var autocapitalizationType: UITextAutocapitalizationType {
        set {
            textField.autocapitalizationType = newValue
        }
        get {
            textField.autocapitalizationType
        }
    }

    var autocorrectionType: UITextAutocorrectionType {
        set {
            textField.autocorrectionType = newValue
        }
        get {
            textField.autocorrectionType
        }
    }

    var keyboardType: UIKeyboardType {
        set {
            textField.keyboardType = newValue
        }
        get {
            textField.keyboardType
        }
    }

    var keyboardAppearance: UIKeyboardAppearance {
        set {
            textField.keyboardAppearance = newValue
        }
        get {
            textField.keyboardAppearance
        }
    }

    var returnKeyType: UIReturnKeyType {
        set {
            textField.returnKeyType = newValue
        }
        get {
            textField.returnKeyType
        }
    }

    weak var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }

    private var state: State
    private var style: Style
    private var minimized: Bool = true
    private let autoMinimizesHelper: Bool
    private let showsPlaceholderWhenFocused: Bool
    private let usesHelperTextAsPlaceholder: Bool
    private let isReadOnly: Bool

    private var internalPlaceholderText: String?

    init(
        state: State = .enabled,
        style: Style = StockStyle(),
        autoMinimizesHelper: Bool = true,
        showsPlaceholderWhenFocused: Bool = false,
        usesHelperTextAsPlaceholder: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.state = state
        self.style = style
        self.autoMinimizesHelper = autoMinimizesHelper
        self.showsPlaceholderWhenFocused = showsPlaceholderWhenFocused
        self.usesHelperTextAsPlaceholder = usesHelperTextAsPlaceholder
        self.isReadOnly = isReadOnly

        super.init(frame: .zero)

        configure()
    }

    private func configure() {
        addViews()
        configureAppearance()
        configureLayout()
        updateView()

        setMinimized(true, force: true)
        subscribeForEditingUpdates()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func subscribeForEditingUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceholderInputField.textFieldDidBeginEditing),
                                               name: UITextField.textDidBeginEditingNotification,
                                               object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceholderInputField.textFieldDidEndEditing),
                                               name: UITextField.textDidEndEditingNotification,
                                               object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceholderInputField.textFieldDidChangeEditing),
                                               name: UITextField.textDidChangeNotification,
                                               object: textField)
    }

    @objc private func textFieldDidBeginEditing() {
        if !autoMinimizesHelper {
            placeholderLabel.isHidden = !showsPlaceholderWhenFocused
        }
        setMinimized(false)
    }

    @objc private func textFieldDidEndEditing() {
        if !autoMinimizesHelper {
            placeholderLabel.isHidden = !(textField.text?.isEmpty ?? true)
        }
        setMinimized(textField.text?.isEmpty ?? true)
    }

    @objc private func textFieldDidChangeEditing() {
        placeholderLabel.isHidden = true
    }

    func setPlaceholder(_ placeholder: String) {
        self.placeholderLabel.text = placeholder
        internalPlaceholderText = placeholder
    }

    func setHelper(_ helper: String) {
        self.helperLabel.text = helper
        if usesHelperTextAsPlaceholder {
            placeholderLabel.text = helper
        }
    }

    /// Sets input's text
    /// - Parameters:
    ///   - text: text we want to be setted
    ///   - animated: update text animated or not
    func setText(_ text: String, animated: Bool = true) {
        if !isFirstResponder {
            setMinimized(text.isEmpty, animated: animated)
        }
        if usesHelperTextAsPlaceholder, !text.isEmpty {
            placeholderLabel.isHidden = true
        }
        textField.text = text
    }

    /// Sets input's attributedText
    /// - Parameters:
    ///   - text: attributed text we want to be setted
    ///   - animated: update text animated or not
    func setAttributedText(_ text: NSAttributedString, animated: Bool = true) {
        setMinimized(false, animated: animated)
        textField.attributedText = text
    }

    func setState(state: State) {
        self.state = state

        textField.isUserInteractionEnabled = state != .disabled && !isReadOnly

        updateView()
    }

    private func updateView() {
        let style = style.styleForState(state)
        applyStyle(style)
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }

    override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }

    override var canResignFirstResponder: Bool {
        textField.canResignFirstResponder
    }

    /// TV OS
    override var canBecomeFocused: Bool {
        textField.canBecomeFocused
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateView()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: .spacing1000)
    }

    private func addViews() {
        addSubview(stackView)
        addSubview(placeholderLabel)
        addSubview(currencyLabel)

        textFieldContainer.addSubview(leftAccessoryStackView)
        textFieldContainer.addSubview(textField)
        stackView.addArrangedSubviews([
            helperLabel, textFieldContainer
        ])
    }

    private func configureAppearance() {
        currencyLabel.isHidden = true
        currencyLabel.isUserInteractionEnabled = false

        placeholderLabel.font = style.inputPlaceholderFont
        textField.font = style.inputTextFont
        currencyLabel.font = style.inputTextFont
        helperLabel.font = style.titleFont
    }

    private func configureLayout() {
        stackView.snp.makeConstraints {
            $0.centerY.directionalHorizontalEdges.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
        }

        textField.snp.makeConstraints {
            $0.height.equalTo(CGFloat.spacing600)
            $0.directionalVerticalEdges.equalToSuperview()
            $0.leading.equalToSuperview().priority(.medium)
            textFieldTrailing = $0.trailing.equalToSuperview().constraint
        }

        leftAccessoryStackView.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(CGFloat.spacing050)
            $0.leading.equalToSuperview()
            textFieldLeading = $0.trailing.equalTo(textField.snp.leading).constraint
        }

        placeholderLabel.snp.makeConstraints {
            $0.edges.equalTo(textField.snp.edges)
        }

        currencyLabel.snp.makeConstraints {
            $0.directionalVerticalEdges.equalTo(textField.snp.directionalVerticalEdges)
            currencyLeading = $0.leading.equalTo(textField.snp.leading).constraint
        }
    }

    private func applyStyle(_ style: Style) {
        self.placeholderLabel.textColor = style.inputPlaceholderColor
        self.helperLabel.textColor = style.titleColor
        self.textField.textColor = style.inputTextColor
        self.textField.tintColor = style.tintColor
        self.currencyLabel.textColor = style.inputTextColor
    }

    func setInputLeadingOffset(offset: CGFloat) {
        textFieldLeading?.update(offset: -offset)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setMinimized(_ minimized: Bool, force: Bool = false, animated: Bool = false) {
        guard autoMinimizesHelper else {
            return
        }

        guard force == false else {
            minimized ? minimize(animated) : maximize(animated)
            return
        }

        if minimized == true, self.minimized == false {
            minimize(animated)
        } else if minimized == false, self.minimized == true {
            maximize(animated)
        }
    }

    func minimize(_ animated: Bool = false) {
        minimized = true
        helperLabel.layer.removeAllAnimations()
        placeholderLabel.layer.removeAllAnimations()

        let placeholderInitialFrame = helperLabel.convert(helperLabel.bounds, to: self)

        let helperFinalFrame = helperLabel.frame
        let placeholderFinalFrame = textField.frame

        placeholderLabel.frame = placeholderInitialFrame

        if usesHelperTextAsPlaceholder {
            placeholderLabel.text = helperLabel.text
        }

        helperLabel.isHidden = true
        placeholderLabel.isHidden = false

        let animations = {
            self.helperLabel.frame = helperFinalFrame
            self.placeholderLabel.frame = placeholderFinalFrame

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        let completion: (Bool) -> Void = { [weak self] _ in
            guard let self, minimized else {
                return
            }
            self.helperLabel.isHidden = true
            self.placeholderLabel.isHidden = false
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    func maximize(_ animated: Bool = true) {
        minimized = false
        helperLabel.layer.removeAllAnimations()
        placeholderLabel.layer.removeAllAnimations()

        let placeholderInitialFrame = helperLabel.convert(helperLabel.bounds, to: self)

        let helperFinalFrame = helperLabel.frame
        let placeholderFinalFrame = textField.frame

        if usesHelperTextAsPlaceholder {
            placeholderLabel.text = internalPlaceholderText
        }

        helperLabel.frame = placeholderInitialFrame
        helperLabel.isHidden = false

        let animations = {
            self.helperLabel.frame = helperFinalFrame

            if !self.showsPlaceholderWhenFocused {
                self.placeholderLabel.frame = placeholderFinalFrame
                self.placeholderLabel.alpha = 0.0
            }

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        let completion: (Bool) -> Void = { [weak self] _ in
            guard let self, !minimized else {
                return
            }
            if !self.showsPlaceholderWhenFocused {
                self.placeholderLabel.alpha = 1.0
                self.placeholderLabel.isHidden = true
            }
            self.helperLabel.isHidden = false
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
}

extension Array where Element == UIView? {
    func setHidden(_ hidden: Bool) {
        _ = self.compactMap { $0?.isHidden = hidden }
    }
}
