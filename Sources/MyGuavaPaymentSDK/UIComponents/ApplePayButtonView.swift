//
//  ApplePayButtonView.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 11.06.2025.
//

import UIKit
import SnapKit
import PassKit

final class ApplePayButtonView: UIView {

    var onTap: (() -> Void)?

    private let titleAttributedString: NSMutableAttributedString = {
        let plainText = "Pay with "
        let boldText = "Pay"
        let attributedText = NSMutableAttributedString(
            string: plainText,
            attributes: [.font: UIFont.title3Regular, .foregroundColor: UIColor.systemBackground]
        )
        attributedText.append(
            NSAttributedString(
                string: boldText,
                attributes: [.font: UIFont.title2Semibold, .foregroundColor: UIColor.systemBackground]
            )
        )
        return attributedText
    }()

    private lazy var button: UIButton = {
        let button: UIButton

        if #available(iOS 14.0, *) {
            let pkButton = PKPaymentButton(paymentButtonType: .inStore, paymentButtonStyle: .automatic)
            pkButton.cornerRadius = UICustomization.Button.cornerRadius
            button = pkButton
        } else {
            button = UIButton()
            button.backgroundColor = .label
            button.clipsToBounds = true
            button.layer.cornerRadius = UICustomization.Button.cornerRadius
            button.setAttributedTitle(titleAttributedString, for: .normal)
        }

        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        return button
    }()

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
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

    private func configureView() {
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }

        addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        isSkeletonable = true
        showShimmerIfNeeded()
    }

    /// Shows shimmer loading
    func showLoading() {
        button.isHidden = true
        isLoading = true
    }

    /// Hides shimmer loading
    func hideLoading() {
        button.isHidden = false
        isLoading = false
    }
}

// MARK: - ApplePayButtonView + ShimmerableView

extension ApplePayButtonView: ShimmerableView {
    var shimmeringViews: [UIView] {
        [self]
    }

    var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [self: .value(Int(UICustomization.Button.cornerRadius))]
    }
}
