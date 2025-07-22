# MyGuava Payment iOS SDK
<!-- toc -->

## Installation

**Minimum requirements:**  
- iOS 13.0+  
- Xcode 13+  
- Swift 5.5+

### Add via Swift Package Manager

1. Open your Xcode project.
2. Go to **File → Add Packages...**
3. Enter the package URL:  
```https://github.com/GuavaPay/myguava-business-payment-sdk-ios.git```

4. Select the latest version.
5. Choose the target to which you want to add the SDK.
6. Click **Add Package**.

After adding `MyGuavaPaymentSDK`, all required dependencies (including Guavapay3DS2) will be installed automatically.

**Import in your code:**
```swift
import MyGuavaPaymentSDK
```

### Required configuration

1. Info.plist

To support secure WebSocket connections used by the SDK, add to your app’s Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsForWebSockets</key>
    <true/>
</dict>
```

2. Apple Pay Setup

Follow the official [Apple Pay instruction](https://developer.apple.com/documentation/passkit/setting-up-apple-pay).

Pass the processing certificate and merchant ID created during the procedure to MyGuava Business support for successful integration.

> **_NOTE:_** UnionPay is not supported by the current version of MyGuava Payment iOS SDK.


## Initialization & Usage

No SDK initialization is required in `AppDelegate` or `SceneDelegate`.  
All integration happens at the point where you present the payment sheet.

### Required parameters

To launch the payment sheet, you need:
- **orderId**: `String`
- **sessionToken**: `String`
- **environment**: `GPEnvironment`
    - `.sandbox`
    - `.production`

### Optional parameters

To configure supported payment methods pass your lists of:
- **uiCustomization**: `GPUICustomization`
    - `common`: `GPCommonCustomization` - Common appearance customization.
    - `button`: `GPButtonCustomization` - Button appearance customization.
    - `label`: `GPLabelCustomization` - Label appearance customization
    - `input`: `GPInputCustomization` - Input field appearance customization.
    - `selectItem`: `GPSelectItemCustomization` - Selection item appearance customization.
- **availableCardSchemes**: `[PaymentCardScheme]`
    - `.visa`
    - `.mastercard`
    - `.unionpay`
    - `.americanExpress`
- **availablePaymentMethods**: `[PaymentMethod]`
    - `.paymentCard`
    - `.applePay`
- **availableCardProductCategories**: `[PaymentCardProductCategory]`
    - `.debit`
    - `.credit`
    - `.prepaid`

These parameters are typically obtained from your backend by creating an order.  
If you need to restrict available methods, card schemes, or product categories, pass the optional parameters in `PaymentConfig`.

### Example: Creating an Order and Presenting the Payment Sheet

> **_WARNING_**:
> Register orders using your backed.
> 
> Do not pass the API key to the mobile client. Only the session token and order ID created on order registration must be passed to the mobile client.



```swift
networkService.createOrder(amount: 10.09, currency: "GBP") { [weak self] result in
    switch result {
    case .success(let order):
        let sessionToken = order.order?.sessionToken
        let orderId = order.order?.id
        let paymentBottomSheetVC = PaymentAssembly.assemble(
            PaymentConfig(
                sessionToken: sessionToken,
                orderId: orderId,
                environment: NetworkService.shared.environment
                // Optionally:
                // uiCustomization: GPUICustomization(
                //     common: .default,
                //     button: .default,
                //     label: .default,
                //     input: .default,
                //     selectItem: .default
                // ),
                // availableCardSchemes: [.visa, .mastercard],
                // availablePaymentMethods: [.paymentCard, .applePay],
                // availableCardProductCategories: [.debit, .credit]
            ),
            self // Your view controller that implements PaymentDelegate
        )

        paymentBottomSheetVC.modalPresentationStyle = .overFullScreen         // mandatory step
        self?.present(paymentBottomSheetVC, animated: false, completion: nil) // animated: false is mandatory too

    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Handling Payment Results

Your view controller should conform to PaymentDelegate to receive payment results:

```swift
extension YourViewController: PaymentDelegate {
    func handlePaymentResult(_ result: PaymentStatus) {
        // Handle payment result: .success, .unsuccess, .error, .cancel
    }

    func handlePaymentResult(_ result: Result<SuccessfulDataModel, TransactionError>) {
        // Handle payment result (success or failure)
        // in `SuccessfulDataModel.orderStatus: OrderStatus`
    }

    func handlePaymentCancel() {
        // Handle user cancellation
    }

    func handleOrderDidNotGet() {
        // Handle case where order could not be fetched
    }
}
```

> **_NOTE_**:
> - All payment method options (Payment Card, Apple Pay) are available by default.
> - The set of available options can be customized via PaymentConfig if needed.
> - You only need to implement PaymentDelegate to receive payment callbacks.

### Handling Callbacks

All payment results, including completion, error, cancellation, and Apple Pay-specific events, are delivered to the PaymentDelegate you provide when presenting the sheet.  
No extra subscriptions or configuration are needed:
just set up your config and implement the delegate for full payment flow support.

### Environment Switching

The SDK supports different environments (sandbox, production).  
You can switch environments via the environment parameter in PaymentConfig.
