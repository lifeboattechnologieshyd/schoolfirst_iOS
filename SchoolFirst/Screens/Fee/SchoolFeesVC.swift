//
//  SchoolFeesVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit
import CashfreePG
import CashfreePGCoreSDK
import CashfreePGUISDK

class SchoolFeesVC: UIViewController {
    
    var feeDetails: StudentFeeDetails!

    @IBOutlet weak var studentImg: UIImageView!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var studentnameLbl: UILabel!
    @IBOutlet weak var totalfeedueLbl: UILabel!
    @IBOutlet weak var dueDate: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var feeVw: UIView!
    @IBOutlet weak var fineamountLbl: UILabel!
    @IBOutlet weak var partpaymentBtn: UIButton!
    @IBOutlet weak var fineLbl: UILabel!
    @IBOutlet weak var payfullBtn: UIButton!
    @IBOutlet weak var installmentsNoLbl: UILabel!
    @IBOutlet weak var feedue: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dueButton: UIButton!
    @IBOutlet weak var remainderLbl: UILabel!
    @IBOutlet weak var dueVw: UIView!
    @IBOutlet weak var dueVwHeight: NSLayoutConstraint!
    
    var isDueVisible = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()

        guard let details = feeDetails else { return }
                
        studentnameLbl.text = details.studentName
        gradeLbl.text = details.gradeName

        if let imageUrl = details.studentImage, !imageUrl.isEmpty {
                studentImg.loadImage(url: imageUrl)
            } else {
                studentImg.image = UIImage(named: "userImage")
            }
            
        let feeDue = details.pendingFee
        let fine = details.finePayable
        let totalDue = feeDue + fine
        
        feedue.text = "₹\(feeDue.rounded())"
        fineamountLbl.text = "₹\(fine.rounded())"
        totalfeedueLbl.text = "₹\(totalDue.rounded())"
        
        let totalInstallments = details.feeInstallments.count
        let paidInstallments = details.feeInstallments.filter {
            $0.feePaid >= $0.payableAmount
        }.count
        
        installmentsNoLbl.text = "\(paidInstallments) / \(totalInstallments)"
        
        if let next = details.feeInstallments.first(where: {
            $0.feePaid < $0.payableAmount
        }) {
            let date = Date(timeIntervalSince1970: next.dueDate / 1000)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            dueDate.setTitle(formatter.string(from: date), for: .normal)
        } else {
            dueDate.setTitle("All Paid", for: .normal)
        }

        remainderLbl.numberOfLines = 0
        remainderLbl.lineBreakMode = .byWordWrapping
        remainderLbl.text = "Only 2 Days remaining. Pay Now to avoid Fine"
        
        dueVw.isHidden = true
        dueVwHeight.constant = 0
        
        feeVw.layer.masksToBounds = false
        feeVw.addCardShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set callback when view appears
        CFPaymentGatewayService.getInstance().setCallback(self)
    }
    
    @IBAction func onClickDue(_ sender: UIButton) {
        toggleDueSection()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickPayFull(_ sender: UIButton) {
        guard let details = feeDetails else { return }
        
        guard let nextInstallment = details.feeInstallments.first(where: { $0.feePaid < $0.payableAmount }) else {
            showAlert(msg: "All installments are already paid!")
            return
        }
        
        let pendingAmount = nextInstallment.payableAmount - nextInstallment.feePaid
        
        createPaymentOrder(
            studentFeeId: details.studentFeeID,
            installmentNumber: nextInstallment.installmentNo,
            amount: pendingAmount
        )
    }
    
    @IBAction func onClickPartPayment(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FeePartPaymentVC") as! FeePartPaymentVC
        vc.feeDetails = feeDetails
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createPaymentOrder(studentFeeId: String, installmentNumber: Int, amount: Double) {
        
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
                        self.startCashfreePayment(
                            orderId: data.orderId,
                            paymentSessionId: data.paymentSessionId
                        )
                    } else {
                        self.showPaymentPopUp(isSuccess: false)
                    }
                    
                case .failure:
                    self.showPaymentPopUp(isSuccess: false)
                }
            }
        }
    }
    
    func startCashfreePayment(orderId: String, paymentSessionId: String) {
        CFPaymentGatewayService.getInstance().setCallback(self)
        
        do {
            let session = try CFSession.CFSessionBuilder()
                .setOrderID(orderId)
                .setPaymentSessionId(paymentSessionId)
                .setEnvironment(CFENVIRONMENT.PRODUCTION)
                .build()
            
            let webCheckout = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(session)
                .build()
            
            try CFPaymentGatewayService.getInstance().doPayment(webCheckout, viewController: self)
            
        } catch let cfError as CFErrorResponse {
            print("❌ Cashfree Error: \(cfError.message ?? "Unknown error")")
            showPaymentPopUp(isSuccess: false)
        } catch {
            print("❌ Payment Error: \(error.localizedDescription)")
            showPaymentPopUp(isSuccess: false)
        }
    }
    
    func showPaymentPopUp(isSuccess: Bool) {
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: false) { [weak self] in
                self?.presentPopUp(isSuccess: isSuccess)
            }
        } else {
            presentPopUp(isSuccess: isSuccess)
        }
    }
    
    private func presentPopUp(isSuccess: Bool) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = sb.instantiateViewController(withIdentifier: "PopUpVC") as? PopUpVC else {
            print("Could not instantiate PopUpVC")
            showFallbackAlert(isSuccess: isSuccess)
            return
        }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        // Set property BEFORE presenting
        vc.isSuccess = isSuccess
        
        present(vc, animated: true)
    }
    
    private func showFallbackAlert(isSuccess: Bool) {
        let title = isSuccess ? "Payment Successful" : "Payment Failed"
        let message = isSuccess
            ? "Thank you! Your payment has been processed successfully."
            : "Your payment couldn't be processed. Please try again later."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if isSuccess {
                self?.navigationController?.popViewController(animated: true)
            }
        })
        
        present(alert, animated: true)
    }
    
    func toggleDueSection() {
        isDueVisible.toggle()
        
        if isDueVisible {
            dueVw.isHidden = false
            dueVwHeight.constant = 50
            remainderLbl.text = "Due date passed 2 days ago. Please Pay the Fee immediately to avoid Late Fee Fine of ₹100 per day"
        } else {
            dueVwHeight.constant = 0
            dueVw.isHidden = true
            remainderLbl.text = "Only 2 Days remaining. Pay Now to avoid Fine"
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension SchoolFeesVC: CFResponseDelegate {
    
    func onSuccess(_ order_id: String) {
        print("✅ Payment Success - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showPaymentPopUp(isSuccess: true)
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        print("❌ Payment Error - Order ID: \(order_id), Error: \(error.message ?? "Unknown")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showPaymentPopUp(isSuccess: false)
        }
    }
    
    func verifyPayment(order_id: String) {
        // ⚠️ THIS IS THE KEY FIX!
        // verifyPayment is called when user cancels/closes payment screen
        // without completing the payment - so treat as FAILURE
        
        print("🔄 Payment Cancelled/Closed - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // ❌ Show FAILURE popup because payment was NOT completed
            self?.showPaymentPopUp(isSuccess: false)
        }
    }
}
