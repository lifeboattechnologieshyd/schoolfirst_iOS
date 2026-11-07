//
//  ReviewpaymentVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import UIKit
import SwiftUI

class ReviewpaymentVC: UIViewController {
    
    // **** Property to receive API data from ChoosepaymentamountVC ****
    var feeResponse: PendingFeeResponse?
    
    private var hostingController: UIHostingController<ReviewPaymentView>?
    private var isPaymentInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSwiftUIView() {
        let swiftUIView = makeSwiftUIView(isLoading: false)
        let hc = UIHostingController(rootView: swiftUIView)
        self.hostingController = hc
        
        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)
        
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        self.isPaymentInProgress = isLoading
        hostingController?.rootView = makeSwiftUIView(isLoading: isLoading)
    }
    
    private func makeSwiftUIView(isLoading: Bool) -> ReviewPaymentView {
        ReviewPaymentView(
            feeData: feeResponse,
            isLoading: isLoading,
            onBack: { [weak self] in
                self?.handleBackNavigation()
            },
            onPay: { [weak self] in
                self?.initiatePayment()
            }
        )
    }
    
    // MARK: - Payment Initiation (Reference from ParentfeeVC)
    
    private func initiatePayment() {
        guard !isPaymentInProgress else { return }
        
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID
        
        print("🔍 [ReviewpaymentVC] studentId: '\(studentId)' | schoolId: '\(schoolId)'")
        
        guard !studentId.isEmpty, !schoolId.isEmpty else {
            print("❌ studentId or schoolId is empty!")
            AlertManager.shared.showAlert(
                title: "Error",
                message: "Student or School information missing."
            )
            return
        }
        
        let payableAmount = feeResponse?.totalPayableAmount ?? 0.0
        guard payableAmount > 0 else {
            print("⚠️ Fee is already fully paid or 0!")
            AlertManager.shared.showAlert(
                title: "Fee Paid",
                message: "This fee has already been fully paid."
            )
            return
        }
        
        // Format amount as whole number or decimal (e.g. "1000")
        let amountString: String
        if payableAmount.truncatingRemainder(dividingBy: 1) == 0 {
            amountString = "\(Int(payableAmount))"
        } else {
            amountString = String(format: "%.2f", payableAmount)
        }
        
        updateLoadingState(true)
        
        createPaymentOrder(
            studentId: studentId,
            schoolId: schoolId,
            amount: amountString
        )
    }
    
    // MARK: - Create Payment Order API (FEE_CREATE_PAYMENT_PHONEPE)
    
    private func createPaymentOrder(
        studentId: String,
        schoolId: String,
        amount: String
    ) {
        var parameters: [String: Any] = [
            "student_id": studentId,
            "amount": amount
        ]
        
        let feeIds = feeResponse?.fees.map { $0.studentFeeId }.filter { !$0.isEmpty } ?? []
        if !feeIds.isEmpty {
            parameters["student_fee_ids"] = feeIds
        }
        
        print("📤 Sending create payment order params: \(parameters)")
        
        NetworkManager.shared.request(
            urlString: API.FEE_CREATE_PAYMENT_PHONEPE,
            method: .POST,
            requiresAuth: true,
            parameters: parameters,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<FeePaymentCreationResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let paymentData = response.data {
                        print("✅ Payment order created successfully: \(paymentData.transactionId) | txnNumber: \(paymentData.transactionNumber)")
                        self.startPhonePeCheckout(with: paymentData)
                    } else {
                        self.updateLoadingState(false)
                        print("❌ Payment order creation failed: \(response.description)")
                        AlertManager.shared.showAlert(
                            title: "Payment Error",
                            message: response.description.isEmpty ? "Failed to initiate payment." : response.description
                        )
                    }
                    
                case .failure(let error):
                    self.updateLoadingState(false)
                    print("❌ Failed to create payment: \(error)")
                    AlertManager.shared.showAlert(
                        title: "Error",
                        message: "Failed to initiate payment: \(error.localizedDescription)"
                    )
                }
            }
        }
    }
    
    // MARK: - Start PhonePe Checkout
    
    private func startPhonePeCheckout(with paymentData: FeePaymentCreationResponse) {
        PhonePePaymentManager.shared.initiatePhonePePayment(
            with: paymentData,
            from: self
        ) { [weak self] paymentResult in
            guard let self = self else { return }
            self.handlePaymentResult(paymentResult, paymentData: paymentData)
        }
    }
    
    // MARK: - Handle Payment Result
    
    private func handlePaymentResult(
        _ result: PaymentResultStatus,
        paymentData: FeePaymentCreationResponse
    ) {
        switch result {
        case .success(let paymentInfo):
            print("✅ Payment SUCCESS | txn: \(paymentInfo.transactionId) | verifying with backend...")
            verifyPayment(paymentData: paymentData)
            
        case .pending(let paymentInfo):
            print("⏳ Payment PENDING | txn: \(paymentInfo.transactionId) | verifying with backend...")
            verifyPayment(paymentData: paymentData)
            
        case .failure(let error):
            updateLoadingState(false)
            print("❌ Payment FAILED: \(error.localizedDescription)")
            AlertManager.shared.showAlert(
                title: "Payment Failed",
                message: error.localizedDescription
            )
        }
    }
    
    // MARK: - Verify Payment API (FEE_VERIFY_PAYMENT)
    
    private func verifyPayment(paymentData: FeePaymentCreationResponse) {
        let schoolId = UserManager.shared.resolvedSchoolID
        let txnNumber = paymentData.transactionNumber.isEmpty ? paymentData.transactionId : paymentData.transactionNumber
        
        let parameters: [String: Any] = [
            "transaction_number": txnNumber
        ]
        
        print("🔍 Verifying payment with params: \(parameters)")
        
        NetworkManager.shared.request(
            urlString: API.FEE_VERIFY_PAYMENT,
            method: .POST,
            requiresAuth: true,
            parameters: parameters,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<FeeVerifyPaymentData>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateLoadingState(false)
                
                switch result {
                case .success(let response):
                    print("✅ Verify payment response received: \(response.description)")
                    let verifyData = response.data
                    self.navigateToPaymentSuccess(
                        paymentCreationData: paymentData,
                        verifyData: verifyData
                    )
                    
                case .failure(let error):
                    print("⚠️ Verify payment failed with error: \(error.localizedDescription)")
                    // Navigate to success since PhonePe completed, with fallback data
                    self.navigateToPaymentSuccess(
                        paymentCreationData: paymentData,
                        verifyData: nil
                    )
                }
            }
        }
    }
    
    // MARK: - Navigate to Payment Success Screen
    
    private func navigateToPaymentSuccess(
        paymentCreationData: FeePaymentCreationResponse,
        verifyData: FeeVerifyPaymentData?
    ) {
        let successVC = PaymentsuccessVC()
        successVC.feeResponse = self.feeResponse
        successVC.paymentCreationData = paymentCreationData
        successVC.verifyPaymentData = verifyData
        navigationController?.pushViewController(successVC, animated: true)
    }
    
    private func handleBackNavigation() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
