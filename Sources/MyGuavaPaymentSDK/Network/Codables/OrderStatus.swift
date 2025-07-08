//
//  OrderStatus.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 23.06.2025.
//

public enum OrderStatus: String, Codable {
    case created = "CREATED"
    case paid = "PAID"
    case declined = "DECLINED"
    case partiallyRefunded = "PARTIALLY_REFUNDED"
    case refunded = "REFUNDED"
    case cancelled = "CANCELLED"
    case expired = "EXPIRED"
    case recurrenceActive = "RECURRENCE_ACTIVE"
    case recurrenceClose = "RECURRENCE_CLOSE"
}
