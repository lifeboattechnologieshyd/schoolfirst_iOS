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
        ) { (result: Result<APIResponse<FeePaymentResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.openCashfree(
                            orderId: data.orderId,
                            paymentSessionId: data.paymentSessionId
                        )
                    } else {
                        self.onFailure?(response.description ?? "Failed to create order")
                    }
                    
                case .failure(let error):
                    self.onFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    private func openCashfree(orderId: String, paymentSessionId: String) {
        guard let vc = viewController else { return }
        
        CFPaymentGatewayService.getInstance().setCallback(self)
        
        do {
            let session = try CFSession.CFSessionBuilder()
                .setOrderID(orderId)
                .setPaymentSessionId(paymentSessionId)
                .setEnvironment(CFENVIRONMENT.SANDBOX)  // Change to .PRODUCTION for live
                .build()
            
            let webCheckout = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(session)
                .build()
            
            try CFPaymentGatewayService.getInstance().doPayment(webCheckout, viewController: vc)
            
        } catch let cfError as CFErrorResponse {
            onFailure?(cfError.message ?? "Payment failed")
        } catch {
            onFailure?("Payment failed. Please try again.")
        }
    }
}

extension PaymentHelper: CFResponseDelegate {
    
    func onSuccess(_ order_id: String) {
        DispatchQueue.main.async {
            self.onSuccess?(order_id)
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        DispatchQueue.main.async {
            self.onFailure?(error.message ?? "Payment failed")
        }
    }
    
    func verifyPayment(order_id: String) {}
}
