//
//  SelectCountryCodeInteractor.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

import Foundation

final class SelectCountryCodeInteractor: SelectCountryCodeInteractorInput {

    weak var output: SelectCountryCodeInteractorOutput?

    func getCountries() {
        if let url = Bundle.module.url(forResource: "countries", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([CountryResponse].self, from: data)
                output?.didGetCountries(jsonData)
            } catch {
                print("error:\(error)")
            }
        }
    }
}
