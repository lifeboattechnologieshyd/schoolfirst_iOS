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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topVw.addBottomShadow()
    
        bgVw.layer.shadowColor = UIColor.black.cgColor
        bgVw.layer.shadowOpacity = 0.15
        bgVw.layer.shadowOffset = CGSize(width: 0, height: 4)
        bgVw.layer.masksToBounds = false
        
        colVw.register(
            UINib(nibName: "AmountCell", bundle: nil),
            forCellWithReuseIdentifier: "AmountCell"
        )
        
        colVw.delegate = self
        colVw.dataSource = self
        updateUI()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickFeeSummary(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "FeeSummaryVC"
        ) as! FeeSummaryVC
        
        vc.feeDetails = feeDetails
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickPayNow(_ sender: UIButton) {
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
        
        guard let details = feeDetails else { return }
        
        guard let nextInstallment = details.feeInstallments.first(where: { $0.feePaid < $0.payableAmount }) else {
            showAlert(msg: "All installments are already paid!")
            return
        }
        
        createPaymentOrder(
            studentFeeId: details.studentFeeID,
            installmentNumber: nextInstallment.installmentNo,
            amount: amount
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
    
    func updateUI() {
        guard let feeDetails = feeDetails else { return }
        
        studentNameLbl.text = feeDetails.studentName
        totalFeeLbl.text = "Total: ₹\(feeDetails.totalFee)"
        
        let totalInstallments = feeDetails.feeInstallments.count
        let paidInstallments = feeDetails.feeInstallments.filter { $0.feePaid >= $0.payableAmount }.count
        installmentslbl.text = "\(paidInstallments) / \(totalInstallments)"
        
        colVw.reloadData()
    }
}

extension FeePartPaymentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return amountList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AmountCell",
            for: indexPath
        ) as! AmountCell
        
        cell.amountLbl.text = amountList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAmount = amountList[indexPath.item]
        
        let amountString = selectedAmount
            .components(separatedBy: "(").first ?? ""
        let cleanedAmount = amountString
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        amountTf.text = cleanedAmount
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 40) / 3
        return CGSize(width: width, height: 34)
    }
}

extension FeePartPaymentVC: CFResponseDelegate {
    
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
