//
//  SelectCountryCodeEmptyStateTableViewCell.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit

public class SelectCountryCodeEmptyStateTableViewCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body2Regular
        label.textColor = UICustomization.Label.secondaryTextColor
        label.text = "Nothing found"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAddSubviews()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// If you need to adjust the position of the view inside the cell, you can override this method.
    /// You can also set your own value for the "contentView.directionalLayoutMargins" property inside this method.
    /// To set the indentation boundaries.
    private func configureLayout() {

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }

    private func configureAddSubviews() {
        backgroundColor = UICustomization.Common.backgroundColor
        selectionStyle = .none
        contentView.addSubview(titleLabel)
    }
}
