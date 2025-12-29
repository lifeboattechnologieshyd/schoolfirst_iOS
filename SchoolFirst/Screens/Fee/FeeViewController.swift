//
//  FeeViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/09/25.
//

import UIKit
import CashfreePG
import CashfreePGCoreSDK
import CashfreePGUISDK

class FeeViewController: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var fee_details = [StudentFeeDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        
        tblVw.register(
            UINib(nibName: "FeeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "FeeTableViewCell"
        )
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        getFeeDetails()
        
        topVw.clipsToBounds = false
        topVw.layer.masksToBounds = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topVw.addBottomShadow()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getFeeDetails() {
        NetworkManager.shared.request(urlString: API.FEE_GET_DETAILS, method: .GET) { (result: Result<APIResponse<[StudentFeeDetails]>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.fee_details = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                } else {
                    self.showAlert(msg: info.description)
                }
                
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    func payFullAmount(details: StudentFeeDetails) {
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
    
    func goToPartPayment(details: StudentFeeDetails) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FeePartPaymentVC") as! FeePartPaymentVC
        vc.feeDetails = details
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToFeeSummary(details: StudentFeeDetails) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FeeSummaryVC") as! FeeSummaryVC
        vc.feeDetails = details
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToDueDate(details: StudentFeeDetails) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SchoolFeesVC") as! SchoolFeesVC
        vc.feeDetails = details
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fee_details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeeTableViewCell",
            for: indexPath
        ) as! FeeTableViewCell
        
        let details = fee_details[indexPath.row]
        
        cell.bgView.applyCardShadow()
        cell.setup(details: details)
        
        cell.onPartPayment = { [weak self] in
            self?.goToPartPayment(details: details)
        }
        
        cell.onViewSummary = { [weak self] in
            self?.goToFeeSummary(details: details)
        }
        
        cell.onDueDate = { [weak self] in
            self?.goToDueDate(details: details)
        }
        
        cell.onPayFull = { [weak self] in
            self?.payFullAmount(details: details)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 407
    }
}

extension FeeViewController: CFResponseDelegate {
    
    func onSuccess(_ order_id: String) {
        DispatchQueue.main.async {
            self.showPaymentPopUp(
                isSuccess: true,
                message: "Your payment has been processed successfully.\n\nOrder ID: \(order_id)"
            )
            self.getFeeDetails()
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
