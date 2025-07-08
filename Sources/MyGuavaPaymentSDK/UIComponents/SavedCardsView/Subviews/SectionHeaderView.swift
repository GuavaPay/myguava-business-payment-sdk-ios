//
//  SectionHeaderView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 20.06.2025.
//

import UIKit

final class SectionHeaderView: UITableViewHeaderFooterView {
    /// Header text label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body1Medium
        label.textColor = .foreground.onAccent
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
