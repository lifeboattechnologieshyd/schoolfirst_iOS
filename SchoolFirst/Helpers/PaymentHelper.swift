//
//  PaymentHelper.swift
//  SchoolFirst
//
//  Created by Lifeboat on 27/12/25.
//

import UIKit
import CashfreePG
import CashfreePGCoreSDK
import CashfreePGUISDK

class PaymentHelper: NSObject {
    
    static let shared = PaymentHelper()
    
    private weak var viewController: UIViewController?
    private var onSuccess: ((String) -> Void)?
    private var onFailure: ((String) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func startPayment(
        studentFeeId: String,
        installmentNumber: Int,
        amount: Double,
        from viewController: UIViewController,
        onSuccess: @escaping (String) -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        self.viewController = viewController
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        
        let payload: [String: Any] = [
            "student_fee_id": studentFeeId,
            "installment_number": installmentNumber,
            "amount": amount
        ]
        
        NetworkManager.shared.request(
            urlString: API.FEE_CREATE_PAYMENT,
            method: .POST,
            parameters: payload
        ) { [weak self] (result: Result<APIResponse<FeePaymentResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.openCashfree(
                            orderId: data.orderId,
                            paymentSessionId: data.paymentSessionId
                        )
                    } else {
                        self.onFailure?(response.description ?? "Failed to create order")
                        self.cleanup()
                    }
                    
                case .failure(let error):
                    self.onFailure?(error.localizedDescription)
                    self.cleanup()
                }
            }
        }
    }
    
    private func openCashfree(orderId: String, paymentSessionId: String) {
        guard let vc = viewController else {
            onFailure?("No view controller available")
            cleanup()
            return
        }
        
        CFPaymentGatewayService.getInstance().setCallback(self)
        
        do {
            let session = try CFSession.CFSessionBuilder()
                .setOrderID(orderId)
                .setPaymentSessionId(paymentSessionId)
                .setEnvironment(CFENVIRONMENT.PRODUCTION)  // Change to .PRODUCTION for live
                .build()
            
            let webCheckout = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(session)
                .build()
            
            try CFPaymentGatewayService.getInstance().doPayment(webCheckout, viewController: vc)
            
        } catch let cfError as CFErrorResponse {
            print("❌ Cashfree Error: \(cfError.message ?? "Unknown error")")
            onFailure?(cfError.message ?? "Payment failed")
            cleanup()
        } catch {
            print("❌ Payment Error: \(error.localizedDescription)")
            onFailure?("Payment failed. Please try again.")
            cleanup()
        }
    }
    
    // Clean up references after payment completes
    private func cleanup() {
        viewController = nil
        onSuccess = nil
        onFailure = nil
    }
}

// MARK: - CFResponseDelegate
extension PaymentHelper: CFResponseDelegate {
    
    func onSuccess(_ order_id: String) {
        print("✅ Payment Success - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.onSuccess?(order_id)
            self?.cleanup()
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        print("❌ Payment Error - Order ID: \(order_id), Error: \(error.message ?? "Unknown")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.onFailure?(error.message ?? "Payment failed")
            self?.cleanup()
        }
    }
    
    func verifyPayment(order_id: String) {
        // ⚠️ THIS IS THE KEY FIX!
        // verifyPayment is called when user cancels/closes payment screen
        // without completing the payment - so treat as FAILURE
        
        print("🔄 Payment Cancelled/Closed - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // ❌ Call onFailure because payment was NOT completed
            self?.onFailure?("Payment was cancelled")
            self?.cleanup()
        }
    }
}
