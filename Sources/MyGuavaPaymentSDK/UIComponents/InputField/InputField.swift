//
//  InputField.swift
//  
//
//  Created by Mikhail Kirillov on 18/6/24.
//

import UIKit

open class InputFieldTextProcessor: NSObject, UITextFieldDelegate {
    var didChangeText: ((String) -> Void)?
    /// Callback of textField delegate `textFieldShouldReturn` was triggered
    var didShouldReturn: (() -> Void)?
}

/// InputField Represents a field for entering text.
/// ```
/// ---------- DEMO 1 CASE --------------
/// let input = InputField() // Default state .enabled
/// input.setPlaceholderText("Label") // Allows you to set the placeholder text
/// input.setHelperText("Helper text") // Allows you to set the text of the message that moves up when typing
/// input.setBottomLeftText("Insufficient balance. Enter an amount within your available funds.") // Allows you to set the message text for the left part under the input field
/// input.setBottomRightText("0/100") //  Allows you to set the message text for the right part under the input field
///
///  ---------- DEMO 2 CASE --------------
/// let input = InputField(
///     state: .enabled, // // Allows you to set state
///     helperText: "Helper text", // Allows you to set the text of the message that moves up when typing
///     placeholderText: "Placeholder text", // Allows you to set the placeholder text
///     bottomLeftText: "Bottom Left Text", // Allows you to set the message text for the left part under the input field
///     bottomRightText: "Bottom Right Text", //  Allows you to set the message text for the right part under the input field
///     icon: Icons.hashtag // Allows you to set an icon
///)
/// ```
class InputField: UIView {

   // MARK: - Subviews

    private let mainContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    /// Sets didChangeText callback for current InputFieldTextProcessor
    /// Sets current InputFieldTextProcessor as UITextFieldDelegate for internal textfield
    var didChangeText: ((String) -> Void)? {
        set {
            input.textFieldDelegate = textProcessor
            textProcessor.didChangeText = newValue
        }
        get {
            textProcessor.didChangeText
        }
    }
    
    /// Sets didShouldReturn callback for current InputFieldTextProcessor
    /// Sets current InputFieldTextProcessor as UITextFieldDelegate for internal textfield
    var didShouldReturn: (() -> Void)? {
        set {
            input.textFieldDelegate = textProcessor
            textProcessor.didShouldReturn = newValue
        }
        get {
            textProcessor.didShouldReturn
        }
    }

    private var textProcessor: InputFieldTextProcessor

    /// Input
    lazy var input: PlaceholderInputField = {
        let input = PlaceholderInputField(
            state: .enabled,
            autoMinimizesHelper: autoMinimizesHelper,
            showsPlaceholderWhenFocused: showsPlaceholderWhenFocused,
            usesHelperTextAsPlaceholder: usesHelperTextAsPlaceholder,
            isReadOnly: isReadOnly
        )
        input.textFieldDelegate = textProcessor
        input.leftAccessoryStackView.addArrangedSubview(cardImageView)
        return input
    }()

    let cardImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.setContentCompressionResistancePriority(.required, for: .horizontal)
        image.setContentHuggingPriority(.required, for: .horizontal)
        return image
    }()

    private lazy var backDrop: InputBackDropView = {
        let view = InputBackDropView(state: .enabled, style: currentStyle.backDropStyle)
        return view
    }()

    private let textFieldContainerStackView = UIStackView()

    let rightAccessoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 0
        stack.setContentHuggingPriority(.required, for: .horizontal)
        return stack
    }()

    lazy var leftAccessoryStackView: UIStackView = {
        input.leftAccessoryStackView
    }()

    private let bottomLeftLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        stackView.spacing = .spacing200
        stackView.distribution = .fillProportionally
        stackView.alignment = .top
        return stackView
    }()

    private lazy var spinnerAccessory = {
        let spinner = SpinnerView(size: .small)
        return self.accessoryView(
            accessory: spinner,
            size: currentStyle.accessoryStyle.size,
            padding: currentStyle.accessoryStyle.padding
        )
    }()

    private var iconAccessory: UIView?

    private var styleFactory: StyleFactoryProtocol

    // MARK: - Properties

    private var currentStyle: Style {
        return styleFactory.styleForstate(state)
    }

    private var helperText: String?
    private let handlesFocusedState: Bool
    private let autoMinimizesHelper: Bool
    private let showsPlaceholderWhenFocused: Bool
    private let accessoriesIgnoreTouches: Bool
    private let usesHelperTextAsPlaceholder: Bool
    private let isReadOnly: Bool

    private var placeholderText: String?

    private var customRightAccessoryAction: (() -> Void)?

    weak var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            input.textFieldDelegate = textFieldDelegate
        }
    }

    var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }

    var state: State = .enabled {
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

    /// Forwarded property for setting input view
    var textFieldInputView: UIView? {
        didSet {
            input.textField.inputView = textFieldInputView
        }
    }

    /// Helper label handle
    var helperLabel: UILabel {
        return input.helperLabel
    }

    /// Adds custom UIButton to last index on accessory stack view, adds sets button's size to 40x40
    var rightButton: UIButton? {
        didSet {
            if let button = rightButton {
                rightAccessoryStackView.addArrangedSubview(button)

                button.snp.makeConstraints { make in
                    make.size.equalTo(40)
                }
            }
            updateAccessories()
        }

        willSet {
            if newValue == nil, let rightButton {
                rightButton.removeFromSuperview()
            }
        }
    }

    // MARK: - Init
    
    /// Init
    /// - Parameters:
    ///   - state: Allows you to set the current state for the input
    ///   - textProcessor: use this to format input text, defaults to DefaultTextProcessor
    ///   - helperText: Allows you to set the text of the message that moves up when typing
    ///   - placeholderText: Allows you to set the placeholder text
    ///   - bottomLeftText: Allows you to set the message text for the left part under the input field
    ///   - bottomRightText: Allows you to set the message text for the right part under the input field
    ///   - icon: Allows you to set an icon
    ///   - handlesFocusedState: switches between .enabled & .focused states on editing start & end respectevily
    ///   - autoMinimizesHelper: boolean value that determines whether the helper text automatically minimizes
    ///   - showsPlaceholderWhenFocused: boolean value that determines whether the placeholder is visible when input is focused
    ///   - accessoriesIgnoreTouches: boolean value that determines whether accessory views ignore touch events
    ///   - usesHelperTextAsPlaceholder: boolean value that determines whether helper text is used as a placeholder
    ///   - isReadOnly: flag indicating whether the field is in read-only mode
    ///   - styleFactory: style factory used to generate UI styles
    init(
        state: State = .enabled,
        textProcessor: InputFieldTextProcessor = DefaultTextProcessor(),
        helperText: String? = nil,
        placeholderText: String? = nil,
        bottomLeftText: String? = nil,
        bottomRightText: String? = nil,
        icon: UIImage? = nil,
        handlesFocusedState: Bool = true,
        autoMinimizesHelper: Bool = true,
        showsPlaceholderWhenFocused: Bool = false,
        accessoriesIgnoreTouches: Bool = false,
        usesHelperTextAsPlaceholder: Bool = false,
        isReadOnly: Bool = false,
        styleFactory: StyleFactoryProtocol = StockStyleFactory()
    ) {
        self.state = state
        self.textProcessor = textProcessor
        self.handlesFocusedState = handlesFocusedState
        self.helperText = helperText
        self.placeholderText = placeholderText
        self.bottomLeftText = bottomLeftText
        self.bottomRightText = bottomRightText
        self.autoMinimizesHelper = autoMinimizesHelper
        self.showsPlaceholderWhenFocused = showsPlaceholderWhenFocused
        self.accessoriesIgnoreTouches = accessoriesIgnoreTouches
        self.usesHelperTextAsPlaceholder = usesHelperTextAsPlaceholder
        self.isReadOnly = isReadOnly
        self.styleFactory = styleFactory

        super.init(frame: .zero)

        if let icon {
            iconAccessory = accessoryView(
                accessory: UIImageView(image: icon),
                size: currentStyle.accessoryStyle.size,
                padding: currentStyle.accessoryStyle.padding
            )
        }

        setupView()
        setupLayout()
        applyStyle()
        bindViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    func setupView() {
        input.helperLabel.text = helperText
        input.setPlaceholder(placeholderText ?? "")
        bottomLeftLabel.text = bottomLeftText
        bottomRightLabel.text = bottomRightText

        backDrop.setContentView(textFieldContainerStackView)

        spinnerAccessory.isHidden = true

        if let iconAccessory {
            rightAccessoryStackView.addArrangedSubview(iconAccessory)
        }

        rightAccessoryStackView.addArrangedSubviews([
            spinnerAccessory
        ])

        textFieldContainerStackView.addArrangedSubviews([
            input,
            rightAccessoryStackView
        ])

        bottomStackView.addArrangedSubviews([
            bottomLeftLabel,
            bottomRightLabel
        ])

        mainContainerStackView.addArrangedSubviews([
            backDrop,
            bottomStackView
        ])

        addSubview(mainContainerStackView)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            super.touchesEnded(touches, with: event)
            return
        }

        if !accessoriesIgnoreTouches {
            let accessoryPoint = touch.location(in: rightAccessoryStackView)
            if let accessoryHitView = rightAccessoryStackView.hitTest(accessoryPoint, with: event),
               !accessoryHitView.subviews.isHidden() {
                super.touchesEnded(touches, with: event)
                return
            }
        }
        // Touch is elsewhere in the view; make the textField become first responder
        input.textField.becomeFirstResponder()

        // Call super to ensure normal touch handling
        super.touchesEnded(touches, with: event)
    }

    /// Adds custom UIButton to last index of accessories stack view
    /// - Parameters:
    ///   - image: called in button.setImage for .normal state
    ///   - target: external selctor target
    ///   - selector: external selctor for .touchUpInside event
    func addRightButton(with image: UIImage?, target: Any?, selector: Selector) {
        let customButton = UIButton(type: .custom)
        customButton.setImage(image, for: .normal)
        customButton.addTarget(target, action: selector, for: .touchUpInside)
        rightButton = customButton
    }
    
    /// Adds custom UIButton to last index of accessories stack view
    /// - Parameters:
    ///   - image: called in button.setImage for .normal state
    ///   - action: escaping action closure for .touchUpInside event
    func addRightButton(with image: UIImage?, action: @escaping () -> Void) {
        let customButton = UIButton(type: .custom)
        customButton.setImage(image, for: .normal)
        customButton.addTarget(target, action: #selector(customRightAccessoryActionHandler), for: .touchUpInside)
        customRightAccessoryAction = action
        rightButton = customButton
    }

    func addRightCustomButton(_ button: UIButton) {
        rightAccessoryStackView.addArrangedSubview(button)
        updateAccessories()
    }

    /// Sets input's text
    /// - Parameters:
    ///   - text: text we want to be setted
    ///   - animated: update text animated or not
    func setText(_ text: String, animated: Bool = true) {
        input.setText(text, animated: animated)
    }

    /// Removes last accessory view in stack by calling .removeFromSuperview()
    func removeRightMostAccessory() {
        rightAccessoryStackView.arrangedSubviews.last?.removeFromSuperview()
    }
    
    /// Removes all accessory views in stack by calling .removeFromSuperview()
    func removeAllAccessoryViews() {
        rightAccessoryStackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
    }

    /// Function to set text processor to input
    /// - Parameter textProcessor: custom text processor
    func setTextProcessor(_ textProcessor: InputFieldTextProcessor) {
        self.textProcessor = textProcessor
        input.textFieldDelegate = textProcessor
    }
    
    /// Changes current accessory views constraints
    /// - Parameter padding: new accessory padding used as directionalEdges
    func setAccessoriesViewPadding(padding: UIEdgeInsets) {
        let newStyle = styleFactory.stockStyle.accessoryPadding(padding)
        self.styleFactory = StockStyleFactory(style: newStyle)
        updateView(with: currentStyle)
    }

    /// Changes current accessory views constraints
    /// - Parameter size: new accessory size used for snp constraints
    func setAccessoriesViewSize(size: CGSize) {
        let newStyle = styleFactory.stockStyle.accessorySize(size)
        self.styleFactory = StockStyleFactory(style: newStyle)
        updateView(with: currentStyle)
    }
    
    /// Sets leftside card icon
    /// - Parameters:
    ///   - icon: card UIImage
    ///   - iconWidth: card view width, height is fixed
    ///   - iconTrailingOffset: spacing between
    func setCardIcon(_ icon: UIImage?, iconWidth: CGFloat = 30, iconTrailingOffset: CGFloat = .spacing100) {
        cardImageView.image = icon
        input.setInputLeadingOffset(offset: iconTrailingOffset)
        cardImageView.snp.updateConstraints { make in
            make.width.equalTo(iconWidth)
        }
    }
    
    /// Sets icon to nil, iconWidth & iconTrailingOffset to 0
    func hideCardIcon() {
        setCardIcon(nil, iconWidth: 0, iconTrailingOffset: 0)
    }

    private func setupLayout() {
        mainContainerStackView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }

    private func updateLoading() {
        switch state {
        case .enabled, .blocked:
            spinnerAccessory.isHidden = !isLoading
        default:
            spinnerAccessory.isHidden = true
        }
    }

    private func applyStyle() {
        input.setState(state: state.inputState)
        backDrop.applyStyle(currentStyle.backDropStyle)
        updateAccessories()

        updateView(with: currentStyle)
    }

    private func updateView(with style: Style) {
        updateAccessoryTintColor(view: iconAccessory, tintColor: style.iconTintColor)

        bottomLeftLabel.font = style.inputFieldStyle.titleFont
        bottomRightLabel.font = style.inputFieldStyle.titleFont
        bottomLeftLabel.textColor = style.foregroundColor
        bottomRightLabel.textColor = style.foregroundColor

        bottomStackView.isHidden = (bottomLeftText == nil) && (bottomRightText == nil)
    }

    private func updateAccessoryTintColor(view: UIView?, tintColor: UIColor) {
        view?.subviews.forEach { view in
            guard let imageView = view as? UIImageView else { return }
            let image = imageView.image
            imageView.image = image?.withTintColor(tintColor)
        }
    }

    func bindViews() {
        input.textField.addTarget(self, action: #selector(textFieldDidBecomeActive), for: .editingDidBegin)
        input.textField.addTarget(self, action: #selector(textFieldDidResignActive), for: .editingDidEnd)
    }

    private func updateAccessoryImage(view: UIView?, image: UIImage?, size: CGSize?) {
        view?.subviews.forEach { view in
            guard let imageView = view as? UIImageView else {
                return
            }
            imageView.image = image
            if let size {
                snp.updateConstraints { make in
                    make.size.equalTo(size)
                }
            }
        }
    }

    private func updateAccessories() {
        [
            spinnerAccessory
        ].setHidden(true)
        iconAccessory?.isHidden = false

        switch state {
        case .enabled:
            spinnerAccessory.isHidden = !isLoading
        case .focused:
            break
        case .error:
            break
        case .disabled:
            break
        case .blocked:
            spinnerAccessory.isHidden = !isLoading
        case .success:
            break
        }

        let allAccessoriesIsHidden = rightAccessoryStackView.arrangedSubviews.allSatisfy(\.isHidden)

        rightAccessoryStackView.isHidden = allAccessoriesIsHidden
    }

    private func accessoryView(
        accessory: UIView,
        size: CGSize? = nil,
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
            if let size {
                $0.size.equalTo(size)
            }
            $0.directionalEdges.equalToSuperview().inset(padding)
        }

        return view
    }

    // MARK: - Internal methods

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 256, height: UIView.noIntrinsicMetric)
    }

    @objc
    private func textFieldDidBecomeActive(_ textField: UITextField) {
        guard handlesFocusedState, self.state != .error else {
            return
        }
        self.state = .focused
    }

    @objc
    private func textFieldDidResignActive(_ textField: UITextField) {
        guard handlesFocusedState, self.state != .error else {
            return
        }
        self.state = .enabled
    }


    @objc
    private func customRightAccessoryActionHandler() {
        customRightAccessoryAction?()
    }
}

extension InputField {
    func setPlaceholderText(_ text: String) {
        input.setPlaceholder(text)
        applyStyle()
    }

    func setHelperText(_ text: String) {
        input.setHelper(text)
        applyStyle()
    }

    func setBottomRightText(_ text: String) {
        bottomRightText = text.isEmpty ? nil : text
        bottomRightLabel.text = text.isEmpty ? nil : text
        applyStyle()
    }

    func setBottomLeftText(_ text: String) {
        bottomLeftText = text.isEmpty ? nil : text
        bottomLeftLabel.text = text.isEmpty ? nil : text
        applyStyle()
    }

    func setIconImage(_ image: UIImage?, size: CGSize? = nil) {
        if iconAccessory == nil {
            let iconAccessory = accessoryView(
                accessory: UIImageView(image: image),
                size: size ?? currentStyle.accessoryStyle.size,
                padding: currentStyle.accessoryStyle.padding
            )
            rightAccessoryStackView.addArrangedSubview(iconAccessory)
            self.iconAccessory = iconAccessory
        } else {
            updateAccessoryImage(view: iconAccessory, image: image, size: size)
        }
    }
}

// MARK: - Forwarded methods
extension InputField {
    /// Sets input's attributedText
    func setAttributedText(_ text: NSAttributedString) {
        input.setAttributedText(text)
    }

    var keyboardType: UIKeyboardType {
        set {
            input.keyboardType = newValue
        }
        get {
            input.keyboardType
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        set {
            input.autocapitalizationType = newValue
        }
        get {
            input.autocapitalizationType
        }
    }

    var autoCorrectionType: UITextAutocorrectionType {
        set {
            input.autocorrectionType = newValue
        }
        get {
            input.autocorrectionType
        }
    }

    var keyboardAppearance: UIKeyboardAppearance {
        set {
            input.keyboardAppearance = newValue
        }
        get {
            input.keyboardAppearance
        }
    }

    var returnKeyType: UIReturnKeyType {
        set {
            input.returnKeyType = newValue
        }
        get {
            input.returnKeyType
        }
    }

    override func becomeFirstResponder() -> Bool {
        input.becomeFirstResponder()
    }

    override var isFirstResponder: Bool {
        input.isFirstResponder
    }

    override var canBecomeFirstResponder: Bool {
        input.canBecomeFirstResponder
    }

    override var canResignFirstResponder: Bool {
        input.canResignFirstResponder
    }

    /// TV OS
    override var canBecomeFocused: Bool {
        input.canBecomeFocused
    }
}
