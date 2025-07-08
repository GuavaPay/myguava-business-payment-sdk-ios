//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import Foundation

struct CardScannerModel {
    var number: String?
    var name: String?
    var expireDate: DateComponents?
}

struct CardScannerError: LocalizedError {
    enum Kind { case cameraSetup, photoProcessing, authorizationDenied, capture }
    var kind: Kind
    var underlyingError: Error?
    var errorDescription: String? { (underlyingError as? LocalizedError)?.errorDescription }
}
