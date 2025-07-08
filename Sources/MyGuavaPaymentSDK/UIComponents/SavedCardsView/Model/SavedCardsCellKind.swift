//
//  SavedCardsCellKind.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 24.06.2025.
//

import UIKit

/// SavedCards cell type
enum SavedCardsCellKind: Equatable {
    /// Design card cell configuration
    case card(Binding)
    case addNewCard
    case error
}
