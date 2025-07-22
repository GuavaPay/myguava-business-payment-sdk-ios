//
//  SeparatorWithText.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 12.06.2025.
//

import UIKit
import SnapKit

final class SeparatorWithTextView: UIView {

    private let leftLine: UIView = {
        let view = UIView()
        view.backgroundColor = UICustomization.Common.dividerColor
        return view
    }()

    private let rightLine: UIView = {
        let view = UIView()
        view.backgroundColor = UICustomization.Common.dividerColor
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Or pay by card"
        label.font = .caption1Regular
        label.textColor = UICustomization.Label.secondaryTextColor
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftLine, titleLabel, rightLine])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        isSkeletonable = true
        addSubview(hStack)

        hStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        leftLine.snp.makeConstraints {
            $0.height.equalTo(1)
        }

        rightLine.snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            startShimmering()
        } else {
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

// MARK: - SeparatorWithTextView + ShimmerableView

extension SeparatorWithTextView: ShimmerableView {
    public var shimmeringViews: [UIView] {
        [self]
    }

    public var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [self: .automatic]
    }
}

