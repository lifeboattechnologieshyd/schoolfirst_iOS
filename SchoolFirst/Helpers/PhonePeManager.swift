//
//  PhonePeManager.swift
//  SchoolFirst
//

import Foundation
import UIKit
#if canImport(PhonePePayment)
import PhonePePayment
#endif

class PhonePePaymentManager {

    static let shared = PhonePePaymentManager()

    private init() {}

    // MARK: - Configuration

    private let merchantId = "PGTESTPAYUAT86"

    #if canImport(PhonePePayment)
    private var ppPayment: PPPayment?
    #endif

    // MARK: - Initialize SDK (Call in AppDelegate)

    func initializeSDK() {
        #if canImport(PhonePePayment)
        ppPayment = PPPayment(
            environment: .sandbox,       // ✅ Change to .production for live
            flowId: "schoolfirst_fee",
            merchantId: merchantId,
            enableLogging: true
        )
        print("✅ PhonePe SDK initialized | merchantId: \(merchantId)")
        #else
        print("⚠️ PhonePe SDK not available at compile time. Skipping initialization.")
        #endif
    }

    // MARK: - Start Checkout Payment

    func initiatePhonePePayment(
        with paymentData: FeePaymentCreationResponse,
        from viewController: UIViewController,
        completion: @escaping (PaymentResultStatus) -> Void
    ) {
        #if canImport(PhonePePayment)
        // ✅ Check SDK initialized
        guard let ppPayment = ppPayment else {
            print("❌ PhonePe SDK not initialized")
            initializeSDK()
            guard let pp = self.ppPayment else {
                completion(.failure(PaymentError.invalidResponse))
                return
            }
            startCheckout(
                pp: pp,
                paymentData: paymentData,
                viewController: viewController,
                completion: completion
            )
            return
        }

        // ✅ Check token
        guard !paymentData.token.isEmpty else {
            print("❌ PhonePe token is empty")
            completion(.failure(PaymentError.invalidResponse))
            return
        }

        // ✅ Check orderId
        guard !paymentData.orderId.isEmpty else {
            print("❌ PhonePe orderId is empty")
            completion(.failure(PaymentError.invalidResponse))
            return
        }

        startCheckout(
            pp: ppPayment,
            paymentData: paymentData,
            viewController: viewController,
            completion: completion
        )
        #else
        print("⚠️ PhonePe SDK not integrated. Returning failure to caller.")
        completion(.failure(.invalidResponse))
        #endif
    }

    // MARK: - Private Checkout

    #if canImport(PhonePePayment)
    private func startCheckout(
        pp: PPPayment,
        paymentData: FeePaymentCreationResponse,
        viewController: UIViewController,
        completion: @escaping (PaymentResultStatus) -> Void
    ) {

        print("💳 PhonePe Checkout starting...")
        print("📌 MerchantId: \(merchantId)")
        print("📌 OrderId: \(paymentData.orderId)")
        print("📌 Token: \(paymentData.token.prefix(40))...")
        print("📌 Amount: \(paymentData.amount)")

        // ✅ startCheckoutFlow — correct method for v5.4.0
        pp.startCheckoutFlow(
            merchantId: merchantId,
            orderId: paymentData.orderId,
            token: paymentData.token,
            appSchema: "schoolfirst",
            on: viewController
        ) { [weak self] request, result in
            guard let _ = self else { return }

            DispatchQueue.main.async {

                print("📱 PhonePe callback received")

                switch result {

                // ✅ SUCCESS
                case .success:
                    print("✅ PhonePe Payment SUCCESS")

                    let info = PaymentInfo(
                        transactionId: paymentData.transactionId,
                        orderId: paymentData.orderId,
                        status: "SUCCESS"
                    )
                    completion(.success(info))

                // ❌ FAILURE
                case .failure(let error):
                    print("❌ PhonePe Payment FAILED")
                    print("❌ Error code: \(error.code)")
                    print("❌ Error message: \(error.localizedDescription)")

                    completion(.failure(PaymentError.paymentFailed))

                // ⏳ INTERRUPTED (User cancelled / Pending)
                case .interrupted(let error):
                    print("⏳ PhonePe Payment INTERRUPTED")
                    print("⏳ Error code: \(error.code)")
                    print("⏳ Error message: \(error.localizedDescription)")

                    let info = PaymentInfo(
                        transactionId: paymentData.transactionId,
                        orderId: paymentData.orderId,
                        status: "PENDING"
                    )
                    completion(.pending(info))
                }
            }
        }
    }
    #endif

    // MARK: - Check PhonePe Installed

    func isPhonePeInstalled() -> Bool {
        #if canImport(PhonePePayment)
        return PPPayment.isPhonePeInstalled()
        #else
        return false
        #endif
    }

    // MARK: - Handle Deeplink (Call in AppDelegate/SceneDelegate)

    func handleDeeplink(_ url: URL) -> Bool {
        #if canImport(PhonePePayment)
        return PPPayment.checkDeeplink(url)
        #else
        return false
        #endif
    }
}

// MARK: - Payment Result Enum

enum PaymentResultStatus {
    case success(PaymentInfo)
    case pending(PaymentInfo)
    case failure(PaymentError)
}

// MARK: - Payment Error

enum PaymentError: Error {
    case paymentFailed
    case unknownError
    case networkError
    case invalidResponse

    var localizedDescription: String {
        switch self {
        case .paymentFailed:
            return "Payment failed. Please try again."
        case .unknownError:
            return "An unknown error occurred."
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidResponse:
            return "Invalid payment response."
        }
    }
}

// MARK: - Payment Info

struct PaymentInfo {
    let transactionId: String
    let orderId: String
    let status: String
}
