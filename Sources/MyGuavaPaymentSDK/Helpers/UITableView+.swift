//
//  ContentSizedTableView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class ContentSizedTableView: UITableView {
    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        guard window != nil else {
            return .zero
        }
        layoutIfNeeded()
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: contentSize.height
        )
    }
}
