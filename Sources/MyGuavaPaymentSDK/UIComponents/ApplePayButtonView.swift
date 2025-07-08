//
//  ApplePayButtonView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 11.06.2025.
//

import UIKit
import SnapKit

final class ApplePayButtonView: UIView {
    
    var onTap: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pay with Apple Pay"
        label.textColor = .white
        label.font = UIFont.headlineSemibold
        label.textAlignment = .center
        return label
    }()

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        showShimmerIfNeeded()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .black
        layer.cornerRadius = 8
        clipsToBounds = true
        isSkeletonable = true

        addSubview(titleLabel)

        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            startShimmering()
        } else {
            stopShimmering()
        }
    }

    @objc
    private func handleTap() {
        onTap?()
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

// MARK: - ApplePayButtonView + ShimmerableView

extension ApplePayButtonView: ShimmerableView {
    public var shimmeringViews: [UIView] {
        [self]
    }

    public var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [self: .automatic]
    }
}
