//
//  PutPayment.swift
//  Guavapay3DS2
//

import Foundation

// MARK: - PutPayment
struct PreCreatePayment: Codable {
    struct Requirements: Codable {
        let threedsMethod: ThreeDSMethod?
        let threedsSdkCreateTransaction: ThreeDSSdkCreateTransaction
    }

    let requirements: Requirements
}

struct ThreeDSSdkCreateTransaction: Codable {
    let messageVersion: String
    let directoryServerID: String
}
