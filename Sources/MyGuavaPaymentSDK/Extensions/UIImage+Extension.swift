//
//  UIImage+Extension.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 20.06.2025.
//

import UIKit

extension UIImage {

    /// This initializer is required to generate an image of the specified color.
    /// It is actively used for customizing segmented controls
    /// - Parameters:
    ///   - color: Color for background
    ///   - size: Size. By default 1x1pt
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
