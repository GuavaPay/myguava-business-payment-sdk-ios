//
//  SelectCountryCodeViewController.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

import UIKit
import SnapKit

final class SelectCountryCodeViewController: UIViewController {

    /// Closure to handle search value change.
    var onSearchValueChanged: ((String) -> Void)?

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = Icons.backArrow
        button.setImage(image, for: .normal)
        button.tintColor = .foreground.onAccent
        button.contentHorizontalAlignment = .center
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select country"
        label.font = .body2Semibold
        label.textColor = .foreground.onAccent
        label.textAlignment = .center
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UICustomization.Common.backgroundColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let searchFieldView = SearchFieldView()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UICustomization.Common.backgroundColor
        tableView.register(cellClass: SelectCountryCodeTableViewCell.self)
        tableView.register(cellClass: SelectCountryCodeEmptyStateTableViewCell.self)
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .border.primary
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    var output: SelectCountryCodeViewOutput?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        output?.viewDidLoad()
    }


    private func setupView() {
        view.backgroundColor = UICustomization.Common.backgroundColor
        searchFieldView.placeholder = "Search for a country"

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubviews(
            titleLabel,
            backButton,
            searchFieldView,
            tableView
        )

        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        searchFieldView.valueChanged = { [weak self] text in
            self?.output?.searchValueChangeAction(text)
        }
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.leading.trailing.equalToSuperview()
        }

        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.size.equalTo(CGSize(width: 44, height: 44))
            $0.leading.equalToSuperview().inset(16)
        }

        searchFieldView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchFieldView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc
    private func handleBackButton() {
        output?.didTapBack()
    }

}

extension SelectCountryCodeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let output = output else {
            return
        }
        output.didSelectCountry(output.getCountriesList()[indexPath.row])
        close()
    }
}

extension SelectCountryCodeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let output = output else {
            return UITableViewCell()
        }

        if output.numberOfRows() == 1, output.getCountriesList().isEmpty {
            guard let cell = tableView.dequeue(
                cellClass: SelectCountryCodeEmptyStateTableViewCell.self,
                for: indexPath
            ) else {
                return UITableViewCell()
            }

            tableView.separatorStyle = .none

            return cell
        }

        guard let cell = tableView.dequeue(
            cellClass: SelectCountryCodeTableViewCell.self,
            for: indexPath
        ) else {
            return UITableViewCell()
        }

        tableView.separatorStyle = .singleLine

        let item = output.getCountriesList()[indexPath.row]
        cell.configure(with: item)

        return cell
    }
}


extension SelectCountryCodeViewController: SelectCountryCodeViewInput {
    func reloadData() {
        tableView.reloadData()
    }
}
