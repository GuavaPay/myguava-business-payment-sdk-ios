//
//  SelectCountryCodeTableViewCell.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

import UIKit

public class SelectCountryCodeTableViewCell: UITableViewCell {

    private let flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body2Regular
        label.textColor = UICustomization.Label.textColor
        label.numberOfLines = 0
        return label
    }()

    private let phoneCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .body2Regular
        label.textColor = UICustomization.Label.secondaryTextColor
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

    /// Method for configuring a cell with data. Possible to override
    /// - Parameter viewModel: Data model covered by the protocol
    func configure(with country: CountryResponse) {
        flagImageView.image = Icons.Flags.icon(with: country.countryCode)
        titleLabel.text = country.countryName
        phoneCodeLabel.text = country.phoneCode
    }

    /// If you need to adjust the position of the view inside the cell, you can override this method.
    /// You can also set your own value for the "contentView.directionalLayoutMargins" property inside this method.
    /// To set the indentation boundaries.
    private func configureLayout() {
        flagImageView.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.lessThanOrEqualToSuperview().offset(-10)
            $0.size.equalTo(CGSize(width: 32, height: 32))
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(flagImageView)
            $0.leading.equalTo(flagImageView.snp.trailing).offset(12)
        }

        phoneCodeLabel.snp.makeConstraints {
            $0.centerY.equalTo(flagImageView)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.leading).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }

    private func configureAddSubviews() {
        backgroundColor = UICustomization.Common.backgroundColor
        selectionStyle = .none
        contentView.addSubviews(
            flagImageView,
            titleLabel,
            phoneCodeLabel
        )
    }
}
