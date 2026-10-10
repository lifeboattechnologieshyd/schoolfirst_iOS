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

    // MARK: - Environment Configuration (Auto Dev vs Prod)

    var isDevBuild: Bool {
        #if DEV
        return true
        #else
        if let bundleId = Bundle.main.bundleIdentifier, bundleId.contains(".dev") {
            return true
        }
        return false
        #endif
    }

    var defaultEnvironment: PhonePePayment.Environment {
        return isDevBuild ? .sandbox : .production
    }

    // ✅ Full Sandbox Merchant ID provided by Charan
    var defaultMerchantId: String {
        return isDevBuild ? "M232O4UX2AXM7_2604211147" : "M232O4UX2AXM7"
    }

    #if canImport(PhonePePayment)
    private var ppPayment: PPPayment?
    #endif

    // MARK: - Initialize SDK (Called in AppDelegate)

    func initializeSDK() {
        #if canImport(PhonePePayment)
        print("✅ PhonePe SDK Manager initialized (ready for lazy configuration on checkout)")
        #else
        print("⚠️ PhonePe SDK not available at compile time. Skipping initialization.")
        #endif
    }

    // MARK: - Extract Merchant ID from JWT Token

    private func extractMerchantId(from token: String) -> String? {
        let parts = token.components(separatedBy: ".")
        guard parts.count > 1 else { return nil }
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let mId = json["merchantId"] as? String,
              !mId.isEmpty else {
            return nil
        }
        return mId
    }

    // MARK: - Start Checkout Payment

    func initiatePhonePePayment(
        with paymentData: FeePaymentCreationResponse,
        from viewController: UIViewController,
        completion: @escaping (PaymentResultStatus) -> Void
    ) {
        #if canImport(PhonePePayment)
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

        // ✅ Determine merchantId dynamically
        var activeMerchantId = extractMerchantId(from: paymentData.token) ?? defaultMerchantId

        // Safety fix: If backend sent the half ID "M232O4UX2AXM7", complete it with full suffix
        if activeMerchantId == "M232O4UX2AXM7" && isDevBuild {
            activeMerchantId = "M232O4UX2AXM7_2604211147"
        }

        // Sandbox for DEV, Production for Release
        let isSandbox: Bool = isDevBuild
        let env: PhonePePayment.Environment = isSandbox ? .sandbox : .production

        print("🔍 PhonePe target merchantId: \(activeMerchantId) | env: \(isSandbox ? "SANDBOX" : "PRODUCTION")")

        let pp = PPPayment(
            environment: env,
            flowId: "schoolfirst_fee",
            merchantId: activeMerchantId,
            enableLogging: isDevBuild
        )
        self.ppPayment = pp

        startCheckout(
            pp: pp,
            merchantId: activeMerchantId,
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
        merchantId: String,
        paymentData: FeePaymentCreationResponse,
        viewController: UIViewController,
        completion: @escaping (PaymentResultStatus) -> Void
    ) {

        print("💳 PhonePe Checkout starting...")
        print("📌 MerchantId: \(merchantId)")
        print("📌 OrderId: \(paymentData.orderId)")
        print("📌 Token: \(paymentData.token.prefix(40))...")
        print("📌 Amount: \(paymentData.amount)")

        pp.startCheckoutFlow(
            merchantId: merchantId,
            orderId: paymentData.orderId,
            token: paymentData.token,
            appSchema: "schoolfirst.phonepe",
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

                @unknown default:
                    print("⚠️ PhonePe Payment unknown result state")
                    completion(.failure(PaymentError.paymentFailed))
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

    // MARK: - Deeplink Handling

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
