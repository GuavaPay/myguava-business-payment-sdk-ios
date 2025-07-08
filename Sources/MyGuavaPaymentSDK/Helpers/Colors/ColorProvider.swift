//
//  File.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit

public protocol Brand {
    static var brand100: UIColor { get }
    static var brand200: UIColor { get }
    static var brand300: UIColor { get }
    static var brand400: UIColor { get }
    static var brand500: UIColor { get }
    static var brand600: UIColor { get }
    static var brand700: UIColor { get }
    static var brand800: UIColor { get }
    static var brand900: UIColor { get }
    static var brand1000: UIColor { get }
}

public protocol Brand2 {
    static var brand2_100: UIColor { get }
    static var brand2_200: UIColor { get }
    static var brand2_300: UIColor { get }
    static var brand2_400: UIColor { get }
    static var brand2_500: UIColor { get }
    static var brand2_600: UIColor { get }
    static var brand2_700: UIColor { get }
    static var brand2_800: UIColor { get }
    static var brand2_900: UIColor { get }
    static var brand2_1000: UIColor { get }
}

public protocol Gray {
    static var gray100: UIColor { get }
    static var gray200: UIColor { get }
    static var gray300: UIColor { get }
    static var gray400: UIColor { get }
    static var gray500: UIColor { get }
    static var gray600: UIColor { get }
    static var gray700: UIColor { get }
    static var gray800: UIColor { get }
    static var gray900: UIColor { get }
    static var gray1000: UIColor { get }
}

public protocol Red {
    static var red100: UIColor { get }
    static var red200: UIColor { get }
    static var red300: UIColor { get }
    static var red400: UIColor { get }
    static var red500: UIColor { get }
    static var red600: UIColor { get }
    static var red700: UIColor { get }
    static var red800: UIColor { get }
    static var red900: UIColor { get }
    static var red1000: UIColor { get }
}

public protocol Green {
    static var green100: UIColor { get }
    static var green200: UIColor { get }
    static var green300: UIColor { get }
    static var green400: UIColor { get }
    static var green500: UIColor { get }
    static var green600: UIColor { get }
    static var green700: UIColor { get }
    static var green800: UIColor { get }
    static var green900: UIColor { get }
    static var green1000: UIColor { get }
}

public protocol Blue {
    static var blue100: UIColor { get }
    static var blue200: UIColor { get }
    static var blue300: UIColor { get }
    static var blue400: UIColor { get }
    static var blue500: UIColor { get }
    static var blue600: UIColor { get }
    static var blue700: UIColor { get }
    static var blue800: UIColor { get }
    static var blue900: UIColor { get }
    static var blue1000: UIColor { get }
}

public protocol Yellow {
    static var yellow100: UIColor { get }
    static var yellow200: UIColor { get }
    static var yellow300: UIColor { get }
    static var yellow400: UIColor { get }
    static var yellow500: UIColor { get }
    static var yellow600: UIColor { get }
    static var yellow700: UIColor { get }
    static var yellow800: UIColor { get }
    static var yellow900: UIColor { get }
    static var yellow1000: UIColor { get }
}

public protocol Additional {
    static var additional100: UIColor { get }
}

public typealias ColorProvider = Brand & Brand2 & Gray & Red & Green & Blue & Yellow & Additional
