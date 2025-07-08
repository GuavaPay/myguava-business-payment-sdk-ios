//
//  UITableViewCell + Reusable.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 18.06.2025.
//

import UIKit

protocol Reusable {}

extension Reusable {
    static var reuseId: String {
        String(describing: self)
    }
}

// MARK: - UITableViewCell + Reusable

extension UITableViewCell: Reusable {}

extension UITableView {
    func register<T: UITableViewCell>(cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.reuseId)
    }

    func dequeue<T: UITableViewCell>(cellClass: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: cellClass.reuseId, for: indexPath) as? T
    }
}

// MARK: - UITableViewHeaderFooterView + Reusable

extension UITableViewHeaderFooterView: Reusable {}

extension UITableView {
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(_ cellClass: T.Type) {
        register(cellClass, forHeaderFooterViewReuseIdentifier: cellClass.reuseId)
    }

    func dequeueHeaderFooter<T: UITableViewHeaderFooterView>(_ cellClass: T.Type) -> T? {
        dequeueReusableHeaderFooterView(withIdentifier: cellClass.reuseId) as? T
    }
}
