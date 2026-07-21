//
//  PhonePeManager.swift
//  SchoolFirst
//
//  Created by vamshi on 16 june 2026
//

import Foundation
import UIKit
import PhonePePayment
import CryptoKit

class PhonePeManager: NSObject {
    
    // MARK: - SINGLETON
    static let shared = PhonePeManager()
    
    // MARK: - CONFIGURATION
    
    private let environment: Environment = .sandbox   // change to .production for live
    private let merchantId: String       = "PGTESTPAYUAT86"
    private let appId: String            = ""
    private let paymentEndPoint          = "/pg/v1/pay"
    
    // MARK: - SANDBOX CREDENTIALS
    // ⚠️ FOR TESTING ONLY - Move to backend in production
    
    private let testSaltKey     = "96434309-7796-489d-8924-ab56988a6076"
    private let testSaltIndex   = 1
    
    // MARK: - SDK INSTANCE
    private var ppPayment: PPPayment?
    
    // MARK: - Callback handlers (mirrors PaymentHelper pattern)
    private weak var viewController: UIViewController?
    private var onSuccess: ((String) -> Void)?
    private var onFailure: ((String) -> Void)?
    
    // MARK: - INIT
    private override init() {
        super.init()
        ppPayment = PPPayment(
            environment   : environment,
            enableLogging : true,
            appId         : appId
        )
    }
    
    // MARK: - ═══════════════════════════════════════════════════
    // MARK: - MAIN ENTRY POINT (Backend-driven flow)
    // MARK: - ═══════════════════════════════════════════════════
    
    /// Starts the full PhonePe payment flow:
    /// 1. Calls backend with { student_id, student_fee_ids }
    /// 2. Backend returns base64 body + checksum + orderId
    /// 3. Launches PhonePe SDK PG flow
    /// 4. Returns success/failure via callbacks
    func startPayment(
        studentId          : String,
        studentFeeIds      : [String],
        from viewController : UIViewController,
        onSuccess          : @escaping (String) -> Void,
        onFailure          : @escaping (String) -> Void
    ) {
        
        self.viewController = viewController
        self.onSuccess      = onSuccess
        self.onFailure      = onFailure
        
        // STEP 1: Build backend payload
        let payload: [String: Any] = [
            "student_id"      : studentId,
            "student_fee_ids" : studentFeeIds
        ]
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("💳 PhonePeManager — startPayment()")
        print("   studentId      :", studentId)
        print("   studentFeeIds  :", studentFeeIds)
        print("   payload        :", payload)
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // STEP 2: Call backend to fetch base64 body + checksum + orderId
        NetworkManager.shared.request(
            urlString  : API.FEE_CREATE_PAYMENT_PHONEPE,   // 👈 add this in API struct
            method     : .POST,
            parameters : payload
        ) { [weak self] (result: Result<APIResponse<PhonePePaymentResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        print("✅ PhonePe backend response received")
                        print("   orderId    :", data.orderId)
                        print("   base64Body :", data.base64Body)
                        print("   checksum   :", data.checksum)
                        
                        self.launchPhonePeSDK(
                            base64Body : data.base64Body,
                            checksum   : data.checksum,
                            orderId    : data.orderId
                        )
                    } else {
                        let msg = response.description.isEmpty
                            ? "Failed to create PhonePe order"
                            : response.description
                        print("❌ PhonePe backend returned failure:", msg)
                        self.onFailure?(msg)
                        self.cleanup()
                    }
                    
                case .failure(let error):
                    print("❌ PhonePe backend error:", error)
                    self.onFailure?(error.localizedDescription)
                    self.cleanup()
                }
            }
        }
    }
    
    // MARK: - ═══════════════════════════════════════════════════
    // MARK: - Launch PhonePe SDK
    // MARK: - ═══════════════════════════════════════════════════
    
    private func launchPhonePeSDK(
        base64Body : String,
        checksum   : String,
        orderId    : String
    ) {
        
        guard let ppPayment = ppPayment else {
            onFailure?("PhonePe SDK not initialized")
            cleanup()
            return
        }
        
        guard let vc = viewController else {
            onFailure?("No view controller available")
            cleanup()
            return
        }
        
        let request = DPSTransactionRequest(
            body        : base64Body,
            apiEndPoint : paymentEndPoint,
            checksum    : checksum,
            headers     : [:],
            appSchema   : "schoolfirst.phonepe"
        )
        
        ppPayment.startPG(
            transactionRequest : request,
            on                 : vc,
            animated           : true,
            completion         : { [weak self] req, result in
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    print("💳 PhonePe SDK completion — result:", result)
                    
                    // NOTE: PhonePe SDK returns after flow ends;
                    // verify final status via backend for reliability
                    
                    self.handleSDKResult(result: result, orderId: orderId)
                }
            }
        )
    }
    
    // MARK: - ═══════════════════════════════════════════════════
    // MARK: - Handle SDK Result
    // MARK: - ═══════════════════════════════════════════════════
    
    private func handleSDKResult(result: Any, orderId: String) {
        
        let resultString = "\(result)".uppercased()
        
        if resultString.contains("SUCCESS") {
            print("✅ PhonePe Payment Success — Order ID:", orderId)
            onSuccess?(orderId)
            
        } else if resultString.contains("CANCEL") {
            print("⚠️ PhonePe Payment Cancelled — Order ID:", orderId)
            onFailure?("Payment was cancelled")
            
        } else if resultString.contains("FAIL") || resultString.contains("ERROR") {
            print("❌ PhonePe Payment Failed — Order ID:", orderId)
            onFailure?("Payment failed. Please try again.")
            
        } else {
            print("🔄 PhonePe unknown result → verify with backend:", resultString)
            verifyPaymentWithBackend(orderId: orderId)
        }
        
        cleanup()
    }
    
    // MARK: - ═══════════════════════════════════════════════════
    // MARK: - Verify Payment with Backend (optional)
    // MARK: - ═══════════════════════════════════════════════════
    
    private func verifyPaymentWithBackend(orderId: String) {
        print("🔍 Verifying PhonePe payment with backend for orderId:", orderId)
        // TODO: Implement backend verification if required
        onFailure?("Payment status pending. Please check later.")
    }
    
    // MARK: - ═══════════════════════════════════════════════════
    // MARK: - Cleanup
    // MARK: - ═══════════════════════════════════════════════════
    
    private func cleanup() {
        viewController = nil
        onSuccess      = nil
        onFailure      = nil
    }
    
    // MARK: - ═══════════════════════════════════════════════════
    // MARK: - HANDLE OPEN URL (called from AppDelegate/SceneDelegate)
    // MARK: - ═══════════════════════════════════════════════════
    
    func handleOpenURL(url: URL) -> Bool {
        print("🔗 PhonePe — handleOpenURL:", url.absoluteString)
        return true
    }
    
    // MARK: - ═══════════════════════════════════════════════════
    // MARK: - TEST PAYMENT (SANDBOX ONLY — kept for testing)
    // MARK: - ═══════════════════════════════════════════════════
    
    func initiateTestPayment(
        amount              : Int,
        transactionId       : String,
        from viewController : UIViewController,
        completion          : @escaping (Bool, String) -> Void
    ) {
        
        let payload: [String: Any] = [
            "merchantId"            : merchantId,
            "merchantTransactionId" : transactionId,
            "amount"                : amount * 100,
            "message"               : "Payment for SchoolFirst",
            "merchantUserId"        : "MUID_\(transactionId)",
            "redirectUrl"           : "https://webhook.site/your-webhook-url",
            "redirectMode"          : "GET",
            "callbackUrl"           : "https://webhook.site/your-webhook-url",
            "mobileNumber"          : "9999999999",
            "paymentInstrument"     : [
                "type" : "PAY_PAGE"
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(false, "Failed to serialize payload")
            return
        }
        
        let base64Body = jsonData.base64EncodedString()
        
        print("📦 [TEST] Payload JSON :", String(data: jsonData, encoding: .utf8) ?? "")
        print("📦 [TEST] Base64 Body  :", base64Body)
        
        let stringToHash = base64Body + paymentEndPoint + testSaltKey
        
        guard let dataToHash = stringToHash.data(using: .utf8) else {
            completion(false, "Failed to generate hash data")
            return
        }
        
        let hashedData = SHA256.hash(data: dataToHash)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        let checksum = "\(hashString)###\(testSaltIndex)"
        
        print("🔐 [TEST] Checksum:", checksum)
        
        self.viewController = viewController
        
        let request = DPSTransactionRequest(
            body        : base64Body,
            apiEndPoint : paymentEndPoint,
            checksum    : checksum,
            headers     : [:],
            appSchema   : "schoolfirst.phonepe"
        )
        
        ppPayment?.startPG(
            transactionRequest : request,
            on                 : viewController,
            animated           : true,
            completion         : { req, result in
                DispatchQueue.main.async {
                    completion(true, "Transaction flow ended. Result state: \(result)")
                }
            }
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════
// MARK: - Response Model (add to NetworkManager.swift if needed)
// MARK: - ═══════════════════════════════════════════════════

struct PhonePePaymentResponse: Codable {
    let orderId    : String
    let base64Body : String
    let checksum   : String
    
    enum CodingKeys: String, CodingKey {
        case orderId    = "order_id"
        case base64Body = "base64_body"
        case checksum   = "checksum"
    }
}
