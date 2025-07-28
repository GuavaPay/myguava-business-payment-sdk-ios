//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import Foundation

/// Protocol for cells which need to shimmer loading support
protocol ShimmerableCell: ShimmerableView {
    /// As ShimmerableCell subcribe to ShimmerableView protocol, this function helps us to start loading via cells.
    /// Inside it need to 'startShimmering' function of ShimmerableView
    func showLoading()
    /// As ShimmerableCell subcribe to ShimmerableView protocol, this function helps us to start loading via cells.
    /// Inside it need to 'startShimmering' function of ShimmerableView
    /// Allows you to configure the shimmer depending on the cell. For example, make the shimmer size slightly larger for even cells than for odd cells.
    func showLoading(_ indexPath: IndexPath?)
    /// As ShimmerableCell subcribe to ShimmerableView protocol, this function helps us to hide loading via cells.
    /// Inside it need to 'stopShimmering' function of ShimmerableView
    func hideLoading()
}

extension ShimmerableCell {
    func showLoading(_ indexPath: IndexPath? = nil) {}
}
