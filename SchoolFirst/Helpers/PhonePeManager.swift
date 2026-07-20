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

class PhonePeManager {
    
    // MARK: - SINGLETON
    
    static let shared = PhonePeManager()
    
    // MARK: - CONFIGURATION
    
    private let environment: Environment = .sandbox
    private let merchantId: String       = "PGTESTPAYUAT86"
    private let appId: String            = ""
    
    // MARK: - SANDBOX CREDENTIALS
    // ⚠️ FOR TESTING ONLY - Move to backend in production
    
    private let testSaltKey     = "96434309-7796-489d-8924-ab56988a6076"
    private let testSaltIndex   = 1
    private let paymentEndPoint = "/pg/v1/pay"
    
    // MARK: - SDK INSTANCE
    
    private var ppPayment: PPPayment?
    
    // MARK: - INIT
    
    private init() {
        ppPayment = PPPayment(
            environment   : environment,
            enableLogging : true,
            appId         : appId
        )
    }
    
    // MARK: - INITIATE PAYMENT
    
    func initiatePayment(
        base64Body      : String,
        checksum        : String,
        from viewController : UIViewController,
        completion      : @escaping (Bool, String) -> Void
    ) {
        
        guard let ppPayment = ppPayment else {
            completion(false, "PhonePe SDK not initialized")
            return
        }
        
        let request = DPSTransactionRequest(
            body        : base64Body,
            apiEndPoint : paymentEndPoint,
            checksum    : checksum,
            headers     : [:],
            appSchema   : "schoolfirst.phonepe"
        )
        
        // MARK: - ✅ FIXED: Correct startPG callback syntax
        
        ppPayment.startPG(
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
    
    // MARK: - HANDLE OPEN URL
    
    func handleOpenURL(url: URL) -> Bool {
        return true
    }
    
    // MARK: - TEST PAYMENT (SANDBOX ONLY)
    
    func initiateTestPayment(
        amount          : Int,
        transactionId   : String,
        from viewController : UIViewController,
        completion      : @escaping (Bool, String) -> Void
    ) {
        
        // STEP 1: Create Payload Dictionary
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
        
        // STEP 2: Convert to JSON
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject : payload,
            options        : []
        ) else {
            print("❌ Failed to serialize payload")
            completion(false, "Failed to serialize payload")
            return
        }
        
        // STEP 3: ✅ SINGLE Base64 Encode
        let base64Body = jsonData.base64EncodedString()
        
        print("📦 Payload JSON : \(String(data: jsonData, encoding: .utf8) ?? "")")
        print("📦 Base64 Body  : \(base64Body)")
        
        // STEP 4: Generate SHA256 Checksum
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
        
        print("🔐 Checksum: \(checksum)")
        
        // STEP 5: Initiate Payment
        initiatePayment(
            base64Body : base64Body,
            checksum   : checksum,
            from       : viewController,
            completion : completion
        )
    }
}
