//
//  NewCardCell.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class NewCardCell: UITableViewCell {

    var onChangeDigits: ((String) -> Void)?
    var onFieldEndEditing: ((CardInformationView.Field) -> Void)?
    var onSaveCardTapped: ((Bool) -> Void)?
    var onScanButtonTapped: (() -> Void)?

    private let cardInformationView = CardInformationView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        bindActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardInformationView)

        cardInformationView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bindActions() {
        cardInformationView.onSaveCardTapped = { [weak self] needSaveNewCard in
            self?.onSaveCardTapped?(needSaveNewCard)
        }
        
        cardInformationView.cardNumberView.onChangeDigits = { [weak self] digits in
            self?.onChangeDigits?(digits)
        }
        
        cardInformationView.onFieldEndEditing = { [weak self] field in
            self?.onFieldEndEditing?(field)
        }
    }
}
