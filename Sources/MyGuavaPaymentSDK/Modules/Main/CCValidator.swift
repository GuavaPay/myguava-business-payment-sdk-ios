//
//  CCValidator.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 17.06.2025.
//

import Foundation
import class UIKit.UIImage

enum CreditCardType: Int {
    case AmericanExpress
    case Dankort
    case DinersClub
    case Discover
    case JCB
    case Maestro
    case MasterCard
    case UnionPay
    case VisaElectron
    case Visa
    case NotRecognized

    init(from cardScheme: CardScheme) {
        self = switch cardScheme {
        case .visa:
                .Visa
        case .mastercard:
                .MasterCard
        case .unionpay:
                .UnionPay
        case .americanExpress:
                .AmericanExpress
        case .dinersClub:
                .DinersClub
        case .none:
                .NotRecognized
        }
    }

    var icon: UIImage? {
        switch self {
        case .AmericanExpress:
            Icons.CardScheme.americanExpress
        case .DinersClub:
            Icons.CardScheme.dinersClub
        case .Maestro, .MasterCard:
            Icons.CardScheme.masterCard
        case .UnionPay:
            Icons.CardScheme.unionPay
        case .VisaElectron, .Visa:
            Icons.CardScheme.visa
        default:
            nil
        }
    }
}

final class CCValidator: NSObject {

    class func validate(cardNumber number: String) -> Bool {
        validateLuhnAlgorithm(cardNumber: number.removingWhitespaceAndNewlines())
    }

    private class func validateLuhnAlgorithm(cardNumber number: String) -> Bool {
        guard Int64(number) != nil else {
            // if string is not convertible to int, return false
            return false
        }
        let numberOfChars = number.count
        let numberToCheck = numberOfChars % 2 == 0 ? number : "0" + number

        let digits = numberToCheck.map { Int(String($0)) }

        let sum = digits.enumerated().reduce(0) { (sum, val: (offset: Int, element: Int?)) in
            if (val.offset + 1) % 2 == 1 {
                let element = val.element!
                return sum + (element == 9 ? 9 : (element * 2) % 9)
            }
            // else
            return sum + val.element!
        }
        return sum % 10 == 0
    }
}
