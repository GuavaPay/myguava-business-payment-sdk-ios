//
//  CardNumberState.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 18.06.2025.
//

import Foundation
import class UIKit.UIImage

typealias CardNumberViewModel = CardNumberState.CardNumberViewModel

enum CardNumberState {
    case normal(viewModel: CardNumberViewModel)
    case error(text: String)
    case disable
    
    var viewModel: CardNumberViewModel? {
        guard case let .normal(viewModel) = self else { return nil }
        return viewModel
    }
}

// MARK: - CardNumberViewModel

extension CardNumberState {
    struct CardNumberViewModel {
        let image: UIImage?
    }
}
