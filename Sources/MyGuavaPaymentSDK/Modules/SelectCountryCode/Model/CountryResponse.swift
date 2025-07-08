//
//  CountryResponse.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

import UIKit

public struct CountryResponse: Decodable {
    var countryCode: String
    var countryName: String
    var phoneCode: String
}
