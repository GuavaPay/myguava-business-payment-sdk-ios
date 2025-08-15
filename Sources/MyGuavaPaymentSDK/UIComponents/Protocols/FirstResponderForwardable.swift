//
//  FirstResponderForwardable.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 05.08.2025.
//

import UIKit

protocol FirstResponderForwardable {
    associatedtype ResponderType: UIResponder

    /// The underlying responder to which first-responder actions are forwarded.
    var firstResponderInput: ResponderType { get }

    /// Whether the container is the first responder.
    var isContainerResponder: Bool { get }

    /// Makes the container the first responder.
    @discardableResult
    func becomeContainerResponder() -> Bool

    /// Resigns the container from being first responder.
    @discardableResult
    func resignContainerResponder() -> Bool
}

extension FirstResponderForwardable {
    var isContainerResponder: Bool {
        firstResponderInput.isFirstResponder
    }

    @discardableResult
    func becomeContainerResponder() -> Bool {
        firstResponderInput.becomeFirstResponder()
    }

    @discardableResult
    func resignContainerResponder() -> Bool {
        firstResponderInput.resignFirstResponder()
    }
}
