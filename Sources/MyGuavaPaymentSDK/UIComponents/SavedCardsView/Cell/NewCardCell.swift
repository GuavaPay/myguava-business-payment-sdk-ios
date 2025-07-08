//
//  NewCardCell.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class NewCardCell: UITableViewCell {

    var onSaveCardTapped: (() -> Void)?

    private let cardInformationView = CardInformationView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .background.primary
        selectionStyle = .none

        contentView.addSubview(cardInformationView)

        cardInformationView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }

        cardInformationView.onSaveCardTapped = { [weak self] in
            self?.onSaveCardTapped?()
        }
    }
}
