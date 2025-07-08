//
//  String+Currency.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 01.07.2025.
//


extension String {
    // MARK: - Currencies

    /// £
    static let pound = "£"
    /// €
    static let euro = "€"
    /// $
    static let dollar = "$"
    /// ₣
    static let swissFrank = "₣"
    /// ¥
    static let jpy = "¥"
    /// ₺
    static let turkishLira = "₺"
    /// ₼
    static let manat = "₼"

    static let australianDollar = "A$"

    static let czechKrone = "Kč"

    static let danishKron = "Kr"

    static let hongkongDollar = "HK$"

    static let hungarianForint = "Ft"

    static let israelShakel = "₪"

    static let mexicanPeso = "M$"

    static let newZellandDollar = "NZ$"

    static let romanianLeu = "lei"

    static let polishZloy = "zł"

    static let singaporeDollar = "S$"

    static let southAfricaRand = "R"
    /// C$
    static let canadianUSD = "C$"

    /// GBP
    static let gbp = "GBP"

    /// CAD
    static let cad = "CAD"

    var currencyValue: String {
        switch self {
        case "USD":
            return .dollar
        case "EUR":
            return .euro
        case "GBP":
            return .pound
        case "JPY":
            return .jpy
        case "TRY":
            return .turkishLira
        case "BRL":
            return "R$"
        case "CHF":
            return .swissFrank
        case "AZN":
            return .manat
        case "CAD":
            return .canadianUSD
        case "AUD":
            return .australianDollar
        case "CZK":
            return .czechKrone
        case "DKK":
            return .danishKron
        case "HKD":
            return .hongkongDollar
        case "HUF":
            return .hungarianForint
        case "ILS":
            return .israelShakel
        case "MXN":
            return .mexicanPeso
        case "NOK":
            return .danishKron
        case "NZD":
            return .newZellandDollar
        case "PLN":
            return .polishZloy
        case "RON":
            return .romanianLeu
        case "SEK":
            return .danishKron
        case "SGD":
            return .singaporeDollar
        case "ZAR":
            return .southAfricaRand
        default:
            return ""
        }
    }
}
