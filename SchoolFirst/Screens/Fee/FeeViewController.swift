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
    
    private var currentOrderId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadInitialData()
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
    
    private func setupUI() {
        topVw.addBottomShadow()
        topVw.clipsToBounds = false
        topVw.layer.masksToBounds = false
    }
    
    private func setupTableView() {
        tblVw.register(
            UINib(nibName: "FeeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "FeeTableViewCell"
        )
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.showsVerticalScrollIndicator = false
    }
    
    private func loadInitialData() {
        if FeeViewController.blockRefresh, let cached = FeeViewController.cachedFeeDetails {
            self.fee_details = cached
            self.tblVw.reloadData()
        } else {
            getFeeDetails()
        }
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
        
        NetworkManager.shared.request(
            urlString: API.FEE_GET_DETAILS,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<[StudentFeeDetails]>, NetworkError>) in
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
                    
                case .failure(let error):
                    print("❌ API Error: \(error.localizedDescription)")
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
                        self.currentOrderId = data.orderId
                        self.startCashfreePayment(
                            orderId: data.orderId,
                            paymentSessionId: data.paymentSessionId
                        )
                    } else {
                        FeeViewController.blockRefresh = true
                        self.showPaymentPopUp(isSuccess: false)
                    }
                    
                case .failure:
                    FeeViewController.blockRefresh = true
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
            FeeViewController.blockRefresh = true
            currentOrderId = nil
            showPaymentPopUp(isSuccess: false)
        } catch {
            print("❌ Payment Error: \(error.localizedDescription)")
            FeeViewController.blockRefresh = true
            currentOrderId = nil
            showPaymentPopUp(isSuccess: false)
        }
    }
    
    func showPaymentPopUp(isSuccess: Bool) {
        currentOrderId = nil
        
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
            return
        }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.isSuccess = isSuccess
        
        present(vc, animated: true)
    }
    
    private func verifyPaymentWithBackend(orderId: String) {
        print("🔄 Payment was not completed - Order ID: \(orderId)")
        
        FeeViewController.blockRefresh = true
        currentOrderId = nil
        
        showPaymentPopUp(isSuccess: false)
        
        if let cached = FeeViewController.cachedFeeDetails {
            self.fee_details = cached
            self.tblVw.reloadData()
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
        
        cell.setup(details: details)
        cell.selectionStyle = .none
        
        cell.onPartPayment = { [weak self] in
            self?.goToPartPayment(details: details)
        }
        
        cell.onViewSummary = { [weak self] in
            self?.goToFeeSummary(details: details)
        }
        
        cell.onPayFull = { [weak self] in
            self?.payFullAmount(details: details)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 590
    }
}

extension FeeViewController: CFResponseDelegate {
    
    func onSuccess(_ order_id: String) {
        print("✅ Payment Success - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeeViewController.blockRefresh = false
            FeeViewController.cachedFeeDetails = nil
            self.currentOrderId = nil
            
            self.showPaymentPopUp(isSuccess: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.getFeeDetails()
            }
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        print("❌ Payment Error - Order ID: \(order_id), Error: \(error.message ?? "Unknown")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeeViewController.blockRefresh = true
            self.currentOrderId = nil
            
            self.showPaymentPopUp(isSuccess: false)
            
            if let cached = FeeViewController.cachedFeeDetails {
                self.fee_details = cached
                self.tblVw.reloadData()
            }
        }
    }
    
    func verifyPayment(order_id: String) {
        print("🔄 Payment Verification Called - Order ID: \(order_id)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeeViewController.blockRefresh = true
            self.currentOrderId = nil
            
            self.showPaymentPopUp(isSuccess: false)
            
            if let cached = FeeViewController.cachedFeeDetails {
                self.fee_details = cached
                self.tblVw.reloadData()
            }
        }
    }
}
