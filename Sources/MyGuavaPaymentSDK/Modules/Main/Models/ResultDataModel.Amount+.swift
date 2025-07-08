//
//  ResultDataModel.Amount+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 07.07.2025.
//

import Foundation

extension ResultDataModel.Amount {
    init(from amount: Amount) {
        self.amount = Decimal(amount.baseUnits)
        self.currency = amount.currency
    }
}
