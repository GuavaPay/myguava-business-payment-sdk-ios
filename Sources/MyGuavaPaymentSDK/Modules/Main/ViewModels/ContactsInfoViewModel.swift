//
//  ContactInfoViewModel.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 01.07.2025.
//

final class ContactInfoViewModel {
    
    /// Country phone code number as `+44`
    var countryPhoneCode: String?
    /// Phone number without country code `2045773333`
    var nationalNumber: String?
    /// Contact email address
    var contactEmail: String?
    
    var hasContactInfo: Bool {
        countryPhoneCode?.isEmpty == false ||
        nationalNumber?.isEmpty == false ||
        contactEmail?.isEmpty == false
    }
}
