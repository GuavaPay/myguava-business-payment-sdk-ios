//
//  Button.swift
//
//
//  Created by Mikhail Kirillov on 2/6/24.
//

import UIKit
import Combine

public final class Button: UIView {

    public struct Config {
        public let type: ButtonType
        public let state: State
        public let scheme: Scheme
        public let size: Size

        public init(type: ButtonType, state: State, scheme: Scheme, size: Size) {
            self.type = type
            self.state = state
            self.scheme = scheme
            self.size = size
        }
    }

    /// Represents different button types.
    public enum ButtonType {
        /// A button with an image
        case image(UIImage)
        /// A button with text
        case text(String)
        /// A button with an image followed by text
        case dual(UIImage, String)
        /// A button with text followed by an image
        case dualTrailing(UIImage, String)
    }

    private var state: State {
        didSet {
            self.updateView()
        }
    }

    private var scheme: Scheme {
        didSet {
            self.updateView()
        }
    }

    private let imageView: UIImageView = {
        let imageView =  UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let label = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.textAlignment = .center
        return label
    }()
    private let spinner = SpinnerView()
    private let mainContainer = UIStackView()

    private let config: Config
    private var style: Style
    private var styleFactory: StyleFactory = StockStyleFactory()

    private var customBackgroundColor: UIColor?
    private var customForegroundColor: UIColor?

    private var action: (() -> Void)?
    private var disableStateAction: (() -> Void)?

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    public override var intrinsicContentSize: CGSize {
        switch config.type {
        case .image:
            return CGSize(width: style.height, height: style.height)
        default:
            let size = label.intrinsicContentSize
            return CGSize(
                width: size.width + style.padding.left + style.padding.right,
                height: style.height
            )
        }
    }

    required public init(config: Config, frame: CGRect = .zero, _ action: (() -> Void)? = nil) {
        self.config = config
        self.state = config.state
        self.scheme = config.scheme
        self.action = action
        self.style = styleFactory.makeStyle(state: config.state,
                                            scheme: config.scheme,
                                            size: config.size, 
                                            type: config.type)
        super.init(frame: frame)
        setupView()
        showShimmerIfNeeded()
    }

    /// initialaizes button overriding background color
    /// - Parameters:
    ///   - config: button config
    ///   - customColor: optional custom background color
    ///   - action: optional action
    public init(
        config: Config,
        customBackgroundColor: UIColor? = nil,
        customForegroundColor: UIColor? = nil,
        _ action: (() -> Void)? = nil
    ) {
        self.config = config
        self.state = config.state
        self.scheme = config.scheme
        self.action = action
        self.customBackgroundColor = customBackgroundColor
        self.customForegroundColor = customForegroundColor
        self.style = styleFactory.makeStyle(state: config.state,
                                            scheme: config.scheme,
                                            size: config.size,
                                            type: config.type)
        super.init(frame: .zero)
        setupView()
        showShimmerIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateView()
    }

    public func setState(_ state: State) {
        self.state = state
    }

    public func setText(_ text: String) {
        label.text = text
    }

    public func setImage(_ image: UIImage) {
        imageView.image = image.withRenderingMode(.alwaysTemplate)
    }

    public func setScheme(_ scheme: Scheme) {
        self.scheme = scheme
    }

    public func setStyleFactory(_ factory: StyleFactory) {
        self.styleFactory = factory
        updateView()
    }

    public func setAction(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func setDisableStateAction(_ action: @escaping () -> Void) {
        disableStateAction = action
    }

    private func setupView() {
        clipsToBounds = true
        isSkeletonable = true

        mainContainer.spacing = style.spacing
        mainContainer.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubviews([
            mainContainer,
            spinner
        ])

        switch config.type {
        case let .dual(image, text):
            let subviews = [imageView, label]
            mainContainer.addArrangedSubviews(subviews)
            imageView.image = image.withRenderingMode(.alwaysTemplate)
            label.text = text
        case let .dualTrailing(image, text):
            let subviews = [label, imageView]
            mainContainer.addArrangedSubviews(subviews)
            imageView.image = image.withRenderingMode(.alwaysTemplate)
            label.text = text
        case let .image(image):
            mainContainer.addArrangedSubview(imageView)
            imageView.image = image.withRenderingMode(.alwaysTemplate)
        case let .text(text):
            mainContainer.addArrangedSubview(label)
            label.text = text
        }

        mainContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        switch config.type {
        case .image:
            // Do NOT add spacings constraints for `.image` type
            break
        default:
            mainContainer.snp.makeConstraints { make in
                // minimum required spacings for button to fall back on
                make.leading.greaterThanOrEqualTo(CGFloat.spacing200).priority(.required)
                // preferred spacings will be broken if there is no spase
                make.leading.greaterThanOrEqualTo(style.padding).priority(.low)
            }
        }

        spinner.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.height.equalTo(style.height).priority(.medium)
        }

        updateView()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        switch style.cornerRadius {
        case .full:
            layer.cornerRadius = bounds.height / 2
        default:
            layer.cornerRadius = style.cornerRadius
        }
    }

    private func updateView() {
        guard !isLoading else {
            return
        }

        style = styleFactory.makeStyle(state: state,
                                       scheme: scheme,
                                       size: config.size,
                                       type: config.type)
        if let customBackgroundColor {
            style = style.backgroundColor(customBackgroundColor)
        }

        if let customForegroundColor {
            style = style.foregroundColor(customForegroundColor)
        }

        if case .secondary = scheme, state != .focused {
            layer.borderColor = style.foregroundColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderWidth = 0
        }

        backgroundColor = style.backgroundColor
        label.textColor = style.foregroundColor

        label.font = style.titleFont

        spinner.setColor(style.foregroundColor)
        spinner.setSize(style.spinnerSize)

        mainContainer.isHidden = state == .loading
        spinner.isHidden = state != .loading
        imageView.tintColor = style.foregroundColor
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            startShimmering()
        } else {
            stopShimmering()
            updateView()
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

// MARK: - Button + ShimmerableView

extension Button: ShimmerableView {
    public var shimmeringViews: [UIView] {
        [self]
    }

    public var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [self: .automatic]
    }
}

extension Button {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state != .disabled && state != .loading else { return }
        state = .pressed
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .disabled {
            disableStateAction?()
        }

        guard state != .disabled && state != .loading else { return }
        state = .enabled
        action?()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state != .disabled && state != .loading else { return }
        state = .enabled
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state != .disabled && state != .loading else { return }
        state = .enabled
    }
}
