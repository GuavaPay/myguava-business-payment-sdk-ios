//
//  PaymentProtocols.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

protocol SelectCountryCodeViewInput: AnyObject {
    func reloadData()
}

protocol SelectCountryCodeViewOutput {
    func viewDidLoad()
    func numberOfRows() -> Int
    func getCountriesList() -> [CountryResponse]
    /// Handles changes in the search input value.
    /// - Parameter search: The updated search text.
    func searchValueChangeAction(_ search: String)
    func didSelectCountry(_ country: CountryResponse)
    func didTapBack()
}

protocol SelectCountryCodeInteractorInput {
    func getCountries()
}

protocol SelectCountryCodeInteractorOutput: AnyObject {
    func didGetCountries(_ countries: [CountryResponse])
}

protocol SelectCountryCodeRouterInput: AnyObject {

    func close()
}

protocol SelectCountryCodeModuleInput: AnyObject {

    func configure(_ output: SelectCountryCodeModuleOutput?)
}

public protocol SelectCountryCodeModuleOutput: AnyObject {

    func didSelectCountry(_ country: CountryResponse)
}

