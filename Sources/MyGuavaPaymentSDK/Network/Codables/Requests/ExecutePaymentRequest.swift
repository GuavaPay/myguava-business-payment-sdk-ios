//
//  ExecutePaymentRequest.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 04.08.2025.
//

struct ExecutePaymentRequest: Encodable {
    let paymentMethod: PaymentMethodRequest?
    let deviceData: DeviceDataRequest?
    let bindingCreationIsNeeded: Bool?
    let bindingName: String?
    let exchange: Exchange?
    let payer: PayerRequest?
    let challengeWindowSize: ChallengeWindowSize?
    let priorityRedirectUrl: String?
}

enum PaymentMethodRequest: Encodable {
    case paymentCardMethod(PaymentCardMethod)
    case paymentCardBinding(BindingMethod)

    func encode(to encoder: any Encoder) throws {
        let request: Encodable = switch self {
        case .paymentCardMethod(let request):
            request
        case .paymentCardBinding(let request):
            request
        }

        return try request.encode(to: encoder)
    }
}

enum ChallengeWindowSize: String, Encodable {
    case size250x400 = "SIZE_250_X_400"
    case size390x400 = "SIZE_390_X_400"
    case size500x600 = "SIZE_500_X_600"
    case size600x400 = "SIZE_600_X_400"
    case sizeFullScreen = "FULL_SCREEN"
}

struct DeviceDataRequest: Encodable {
    let browserData: DeviceBrowserData?
    let ip: String?
    let threedsSdkData: ThreedsSdkData?
}

struct Exchange: Encodable {
    let amount: Amount
    let token: String
}

struct DeviceBrowserData: Encodable {
    let acceptHeader: String
    let userAgent: String
    let javaScriptEnabled: Bool
    let language: String
    let screenHeight: Int
    let screenWidth: Int
    let timeZone: Double
    let timeZoneOffset: Double
    let javaEnabled: Bool
    let screenColorDepth: Int
    let sessionId: String
}

struct ThreedsSdkData: Encodable {
    let name: String
    let version: String
    let packedAuthenticationData: String?

    init(name: String = "iOS SDK", version: String = "1.0.0", packedAuthenticationData: String?) {
        self.name = name
        self.version = version
        self.packedAuthenticationData = packedAuthenticationData
    }
}

struct PayerRequest: Encodable {
    let inputMode: [InputMode]?
    let firstName: String?
    let lastName: String?
    let contactEmail: String?
    let contactPhone: ContactPhone?
    let address: Address?
}
