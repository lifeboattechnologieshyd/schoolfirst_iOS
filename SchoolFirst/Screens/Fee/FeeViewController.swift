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
    
    static var blockRefresh = false
    static var cachedFeeDetails: [StudentFeeDetails]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        
        tblVw.register(
            UINib(nibName: "FeeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "FeeTableViewCell"
        )
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        if FeeViewController.blockRefresh, let cached = FeeViewController.cachedFeeDetails {
            self.fee_details = cached
            self.tblVw.reloadData()
        } else {
            getFeeDetails()
        }
        
        topVw.clipsToBounds = false
        topVw.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CFPaymentGatewayService.getInstance().setCallback(self)
        
        if !FeeViewController.blockRefresh {
            getFeeDetails()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topVw.addBottomShadow()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getPendingAmount(details: StudentFeeDetails) -> Double {
        if details.pendingFee > 0 {
            return details.pendingFee
        }
        
        var totalPending: Double = 0
        for installment in details.feeInstallments {
            let pending = installment.payableAmount - installment.feePaid
            if pending > 0 {
                totalPending += pending
            }
        }
        return totalPending
    }
    
    private func findInstallmentToPay(details: StudentFeeDetails) -> FeeInstallment? {
        let sortedInstallments = details.feeInstallments.sorted { $0.installmentNo < $1.installmentNo }
        
        if let unpaidInstallment = sortedInstallments.first(where: { $0.feePaid < $0.payableAmount }) {
            return unpaidInstallment
        }
        
        if details.pendingFee > 0 {
            return sortedInstallments.last
        }
        
        return sortedInstallments.first
    }
    
    func getFeeDetails() {
        if FeeViewController.blockRefresh {
            if let cached = FeeViewController.cachedFeeDetails {
                self.fee_details = cached
                DispatchQueue.main.async {
                    self.tblVw.reloadData()
                }
            }
            return
        }
        
        NetworkManager.shared.request(urlString: API.FEE_GET_DETAILS, method: .GET) { [weak self] (result: Result<APIResponse<[StudentFeeDetails]>, NetworkError>) in
            guard let self = self else { return }
            
            if FeeViewController.blockRefresh { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.fee_details = data
                        FeeViewController.cachedFeeDetails = data
                        self.tblVw.reloadData()
                    }
                    
                case .failure:
                    break
                }
            }
        }
    }
    
    func payFullAmount(details: StudentFeeDetails) {
        let pendingAmount = getPendingAmount(details: details)
        
        if pendingAmount <= 0 {
            showAlert(msg: "All fees are already paid!")
            return
        }
        
        guard let installment = findInstallmentToPay(details: details) else {
            showAlert(msg: "No installment found")
            return
        }
        
        FeeViewController.cachedFeeDetails = self.fee_details
        FeeViewController.blockRefresh = true
        
        createPaymentOrder(
            studentFeeId: details.studentFeeID,
            installmentNumber: installment.installmentNo,
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
                        FeeViewController.blockRefresh = true
                        self.showPaymentPopUp(isSuccess: false, message: response.description ?? "Failed to create order")
                    }
                    
                case .failure(let error):
                    FeeViewController.blockRefresh = true
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
            FeeViewController.blockRefresh = true
            showPaymentPopUp(isSuccess: false, message: cfError.message ?? "Failed to initialize payment.")
        } catch {
            FeeViewController.blockRefresh = true
            showPaymentPopUp(isSuccess: false, message: "Failed to initialize payment. Please try again.")
        }
    }
    
    func showPaymentPopUp(isSuccess: Bool, message: String) {
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: false) { [weak self] in
                self?.presentPopUp(isSuccess: isSuccess, message: message)
            }
        } else {
            presentPopUp(isSuccess: isSuccess, message: message)
        }
    }
    
    private func presentPopUp(isSuccess: Bool, message: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = sb.instantiateViewController(withIdentifier: "PopUpVC") as? PopUpVC else {
            return
        }
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeeViewController.blockRefresh = false
            FeeViewController.cachedFeeDetails = nil
            
            self.showPaymentPopUp(
                isSuccess: true,
                message: "Payment successful!\n\nOrder ID: \(order_id)"
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.getFeeDetails()
            }
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeeViewController.blockRefresh = true
            
            self.showPaymentPopUp(
                isSuccess: false,
                message: error.message ?? "Payment failed."
            )
            
            if let cached = FeeViewController.cachedFeeDetails {
                self.fee_details = cached
                self.tblVw.reloadData()
            }
        }
    }
    
    func verifyPayment(order_id: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeeViewController.blockRefresh = false
            FeeViewController.cachedFeeDetails = nil
            
            self.showPaymentPopUp(
                isSuccess: true,
                message: "Payment successful!\n\nOrder ID: \(order_id)"
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.getFeeDetails()
            }
        }
    }
}
