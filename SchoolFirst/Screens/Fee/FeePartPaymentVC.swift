//
//  FeePartPaymentVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit
import CashfreePG
import CashfreePGCoreSDK
import CashfreePGUISDK

class FeePartPaymentVC: UIViewController {
    
    var feeDetails: StudentFeeDetails!
    var selectedInstallment: FeeInstallment!
        
    @IBOutlet weak var bachButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var feesummaryButton: UIButton!
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var amountTf: UITextField!
    @IBOutlet weak var installmentslbl: UILabel!
    @IBOutlet weak var paynowButton: UIButton!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var totalFeeLbl: UILabel!

    let amountList = [
        "₹15,000 (75%)",
        "₹10,000 (50%)",
        "₹5,000 (25%)",
        "₹2,500 (12.5%)",
        "₹1,000 (5%)",
        "₹500 (2.5%)",
        "₹250 (1.25%)",
        "₹100 (0.5%)",
        "₹50 (0.25%)",
        "₹25 (0.12%)"
    ]
    
    private static var blockRefresh = false
    private static var cachedFeeDetails: StudentFeeDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CFPaymentGatewayService.getInstance().setCallback(self)
        
        if !FeePartPaymentVC.blockRefresh {
            updateUI()
        } else if let cached = FeePartPaymentVC.cachedFeeDetails {
            self.feeDetails = cached
            updateUI()
        }
    }
    
    private func getPendingAmount() -> Double {
        guard let details = feeDetails else { return 0 }
        
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
    
    private func findInstallmentToPay() -> FeeInstallment? {
        guard let details = feeDetails else { return nil }
        
        let sortedInstallments = details.feeInstallments.sorted { $0.installmentNo < $1.installmentNo }
        
        if let unpaidInstallment = sortedInstallments.first(where: { $0.feePaid < $0.payableAmount }) {
            return unpaidInstallment
        }
        
        if details.pendingFee > 0 {
            return sortedInstallments.last
        }
        
        return sortedInstallments.first
    }
    
    private func setupUI() {
        topVw.addBottomShadow()
        
        bgVw.layer.shadowColor = UIColor.black.cgColor
        bgVw.layer.shadowOpacity = 0.15
        bgVw.layer.shadowOffset = CGSize(width: 0, height: 4)
        bgVw.layer.shadowRadius = 4
        bgVw.layer.masksToBounds = false
        
        amountTf.keyboardType = .decimalPad
        amountTf.delegate = self
    }
    
    private func setupCollectionView() {
        colVw.register(
            UINib(nibName: "AmountCell", bundle: nil),
            forCellWithReuseIdentifier: "AmountCell"
        )
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    private func updateUI() {
        guard let feeDetails = feeDetails else { return }
        
        studentNameLbl.text = feeDetails.studentName
        
        let pendingAmount = getPendingAmount()
        if pendingAmount > 0 {
            totalFeeLbl.text = "₹\(String(format: "%.2f", pendingAmount))"
        } else {
            totalFeeLbl.text = "Total: ₹\(feeDetails.totalFee) (Fully Paid)"
        }
        
        let installmentNumbers = feeDetails.feeInstallments
            .map { String($0.installmentNo) }
            .joined(separator: ", ")
        installmentslbl.text = installmentNumbers

        colVw.reloadData()
        
        if pendingAmount <= 0 {
            paynowButton.isEnabled = false
            paynowButton.alpha = 0.5
        } else {
            paynowButton.isEnabled = true
            paynowButton.alpha = 1.0
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickFeeSummary(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FeeSummaryVC") as! FeeSummaryVC
        vc.feeDetails = feeDetails
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickPayNow(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let amountText = amountTf.text, !amountText.isEmpty else {
            showAlert(msg: "Please enter an amount")
            return
        }
        
        let cleanedAmount = amountText
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let amount = Double(cleanedAmount), amount > 0 else {
            showAlert(msg: "Please enter a valid amount")
            return
        }
        
        guard let details = feeDetails else {
            showAlert(msg: "Fee details not found")
            return
        }
        
        let pendingAmount = getPendingAmount()
        
        if pendingAmount <= 0 {
            showAlert(msg: "All fees are already paid!")
            return
        }
        
        guard let installment = findInstallmentToPay() else {
            showAlert(msg: "No installment found")
            return
        }
        
        FeePartPaymentVC.cachedFeeDetails = self.feeDetails
        FeePartPaymentVC.blockRefresh = true
        
        createPaymentOrder(
            studentFeeId: details.studentFeeID,
            installmentNumber: installment.installmentNo,
            amount: amount
        )
    }
    
    func createPaymentOrder(studentFeeId: String, installmentNumber: Int, amount: Double) {
        showLoader()
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
                self.hideLoader()
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.startCashfreePayment(
                            orderId: data.orderId,
                            paymentSessionId: data.paymentSessionId
                        )
                    } else {
                        FeePartPaymentVC.blockRefresh = true
                        self.showPaymentPopUp(isSuccess: false)
                    }
                    
                case .failure:
                    FeePartPaymentVC.blockRefresh = true
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
            FeePartPaymentVC.blockRefresh = true
            showPaymentPopUp(isSuccess: false)
        } catch {
            print("❌ Payment Error: \(error.localizedDescription)")
            FeePartPaymentVC.blockRefresh = true
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
}

extension FeePartPaymentVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension FeePartPaymentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return amountList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmountCell", for: indexPath) as! AmountCell
        cell.amountLbl.text = amountList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAmount = amountList[indexPath.item]
        let amountString = selectedAmount.components(separatedBy: "(").first ?? ""
        let cleanedAmount = amountString
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        amountTf.text = cleanedAmount
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 40) / 3
        return CGSize(width: width, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension FeePartPaymentVC: CFResponseDelegate {
    
    func onSuccess(_ order_id: String) {
        print("✅ Payment Success - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeePartPaymentVC.blockRefresh = false
            FeePartPaymentVC.cachedFeeDetails = nil
            FeeViewController.blockRefresh = false
            FeeViewController.cachedFeeDetails = nil
            
            self.showPaymentPopUp(isSuccess: true)
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        print("❌ Payment Error - Order ID: \(order_id), Error: \(error.message ?? "Unknown")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            FeePartPaymentVC.blockRefresh = true
            
            self.showPaymentPopUp(isSuccess: false)
            
            if let cached = FeePartPaymentVC.cachedFeeDetails {
                self.feeDetails = cached
                self.updateUI()
            }
        }
    }
    
    func verifyPayment(order_id: String) {
        // This is called when user comes back without completing payment
        // or when payment status is uncertain (cancelled/closed)
        print("🔄 Payment Verification Called (User cancelled/closed) - Order ID: \(order_id)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Treat as FAILURE since user came back without completing payment
            FeePartPaymentVC.blockRefresh = true
            
            // Show FAILURE popup
            self.showPaymentPopUp(isSuccess: false)
            
            if let cached = FeePartPaymentVC.cachedFeeDetails {
                self.feeDetails = cached
                self.updateUI()
            }
        }
    }
}
