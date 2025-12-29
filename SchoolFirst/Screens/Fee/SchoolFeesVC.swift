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
        studentImg.loadImage(url: details.studentImage ?? "")
        
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
        ) { (result: Result<APIResponse<FeePaymentResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.startCashfreePayment(
                            orderId: data.orderId,
                            paymentSessionId: data.paymentSessionId
                        )
                    } else {
                        self.showPaymentPopUp(isSuccess: false, message: response.description ?? "Failed to create order")
                    }
                    
                case .failure(let error):
                    self.showPaymentPopUp(isSuccess: false, message: error.localizedDescription)
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
                .setEnvironment(CFENVIRONMENT.SANDBOX)
                .build()
            
            let webCheckout = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(session)
                .build()
            
            try CFPaymentGatewayService.getInstance().doPayment(webCheckout, viewController: self)
            
        } catch let cfError as CFErrorResponse {
            showPaymentPopUp(isSuccess: false, message: cfError.message ?? "Failed to initialize payment.")
        } catch {
            showPaymentPopUp(isSuccess: false, message: "Failed to initialize payment. Please try again.")
        }
    }
    
    func showPaymentPopUp(isSuccess: Bool, message: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        present(vc, animated: true) {
            vc.configure(isSuccess: isSuccess, message: message)
        }
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
        DispatchQueue.main.async {
            self.showPaymentPopUp(
                isSuccess: true,
                message: "Your payment has been processed successfully.\n\nOrder ID: \(order_id)"
            )
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        DispatchQueue.main.async {
            self.showPaymentPopUp(
                isSuccess: false,
                message: error.message ?? "Something went wrong"
            )
        }
    }
    
    func verifyPayment(order_id: String) {
        
    }
}
