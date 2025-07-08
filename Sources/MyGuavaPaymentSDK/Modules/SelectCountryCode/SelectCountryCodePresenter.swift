//
//  SelectCountryCodePresenter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

import Foundation

final class SelectCountryCodePresenter: SelectCountryCodeViewOutput {

    private let interactor: SelectCountryCodeInteractorInput
    private weak var view: SelectCountryCodeViewInput?
    private let router: SelectCountryCodeRouterInput
    private var moduleOutput: SelectCountryCodeModuleOutput?
    private var selectedItem: CountryResponse?
    private var query = ""

    private var countriesWithSearchQuery: [CountryResponse] = []
    private var countries: [CountryResponse] = [] {
        didSet {
            view?.reloadData()
        }
    }

    init(
        interactor: SelectCountryCodeInteractorInput,
        view: SelectCountryCodeViewInput,
        router: SelectCountryCodeRouterInput,
        selectedItem: CountryResponse?
    ) {
        self.interactor = interactor
        self.view = view
        self.router = router
        self.selectedItem = selectedItem
    }

    func viewDidLoad() {
        interactor.getCountries()
    }

    func numberOfRows() -> Int {
        countriesWithSearchQuery.isEmpty ? 1 : countriesWithSearchQuery.count
    }

    func getCountriesList() -> [CountryResponse] {
        countriesWithSearchQuery
    }

    func searchValueChangeAction(_ search: String) {
        query = search.lowercased()

        reloadData()
    }

    private func reloadData() {
        guard !query.isEmpty else {
            countriesWithSearchQuery = countries
            view?.reloadData()
            return
        }

        self.countriesWithSearchQuery = countries.filter { ($0.countryName).lowercased().hasPrefix(query) }

        view?.reloadData()
    }

    func didSelectCountry(_ country: CountryResponse) {
        moduleOutput?.didSelectCountry(country)
    }

    func didTapBack() {
        router.close()
    }
}

extension SelectCountryCodePresenter: SelectCountryCodeInteractorOutput {
    func didGetCountries(_ countries: [CountryResponse]) {
        if let selectedItem = selectedItem {
            self.countries = countries.filter { $0.countryCode != selectedItem.countryCode }
            countriesWithSearchQuery = self.countries
        } else {
            self.countries = countries
            countriesWithSearchQuery = self.countries
        }
    }
}

extension SelectCountryCodePresenter: SelectCountryCodeModuleInput {
    func configure(_ output: SelectCountryCodeModuleOutput?) {
        moduleOutput = output
    }
}
