//
//  CardSecurityCodeState.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 04.07.2025.
//

import Foundation

enum CardSecurityCodeState {
    case normal
    case error(text: String)
    case disable
}
