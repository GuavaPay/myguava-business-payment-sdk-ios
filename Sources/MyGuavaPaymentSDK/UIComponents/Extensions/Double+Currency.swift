//
//  Double+Currency.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 01.07.2025.
//

import Foundation

extension Double {
    /// € 5 454.00
    func formattedStringWithCurrency(
        _ currency: String,
        minimumFractionDigits: Int = 2,
        maximumFractionDigits: Int = 2
    ) -> String {
        let currencySeparator: String = "\u{00a0}"

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        return "\(currency.currencyValue)\(currencySeparator)" +
        (formatter.string(from: NSNumber(value: self)) ?? String(format: "%.2f", self))
    }
}
