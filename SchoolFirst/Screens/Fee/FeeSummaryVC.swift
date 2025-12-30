//
//  FeeSummaryVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class FeeSummaryVC: UIViewController {
    
    var feeDetails: StudentFeeDetails!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var annualAmountLbl: UILabel!
    @IBOutlet weak var paidAmountLbl: UILabel!
    @IBOutlet weak var viewTransactionBtn: UIButton!
    @IBOutlet weak var progressVw: UIProgressView!
    @IBOutlet weak var balanceAmountLbl: UILabel!
    @IBOutlet weak var studentImg: UIImageView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topVw.addBottomShadow()
        setupStudentInfo()
        setupTableView()
    }
    
    private func setupStudentInfo() {
        studentNameLbl.text = feeDetails.studentName
        gradeLbl.text = feeDetails.gradeName
        studentImg.loadImage(url: feeDetails.studentImage ?? "")

        annualAmountLbl.text = "₹\(feeDetails.totalFee)"
        paidAmountLbl.text = "₹\(feeDetails.feePaid)"
        balanceAmountLbl.text = "₹\(feeDetails.pendingFee)"

        let progress = Float(feeDetails.feePaid / feeDetails.totalFee)
        progressVw.progress = progress
    }
    
    private func setupTableView() {
        tblVw.register(
            UINib(nibName: "FeeSummaryCell", bundle: nil),
            forCellReuseIdentifier: "FeeSummaryCell"
        )
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickViewTransaction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "FeeTransactionsVC"
        ) as! FeeTransactionsVC
        
        vc.feeDetails = self.feeDetails
        navigationController?.pushViewController(vc, animated: true)
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
            showFallbackAlert(isSuccess: isSuccess, message: message)
            return
        }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        present(vc, animated: true) {
            vc.configure(isSuccess: isSuccess, message: message)
        }
    }
    
    private func showFallbackAlert(isSuccess: Bool, message: String) {
        let title = isSuccess ? "Payment Successful" : "Payment Failed"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if isSuccess {
                self?.navigationController?.popViewController(animated: true)
            }
        })
        
        present(alert, animated: true)
    }
}

extension FeeSummaryVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return feeDetails.feeInstallments.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeeSummaryCell",
            for: indexPath
        ) as! FeeSummaryCell

        let installment = feeDetails.feeInstallments[indexPath.row]
        cell.configure(with: installment, feeDetails: feeDetails)
       
        cell.onPayFull = { [weak self] in
            guard let self = self else { return }
            
            let pendingAmount = installment.payableAmount - installment.feePaid
            
            PaymentHelper.shared.startPayment(
                studentFeeId: self.feeDetails.studentFeeID,
                installmentNumber: installment.installmentNo,
                amount: pendingAmount,
                from: self,
                onSuccess: { orderId in
                    // ✅ Success Popup
                    self.showPaymentPopUp(
                        isSuccess: true,
                        message: "Payment successful!\n\nOrder ID: \(orderId)"
                    )
                },
                onFailure: { error in
                    // ❌ Failure Popup
                    self.showPaymentPopUp(
                        isSuccess: false,
                        message: error
                    )
                }
            )
        }
           cell.onPartPayment = { [weak self] in
            guard let self = self else { return }
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(
                withIdentifier: "FeePartPaymentVC"
            ) as! FeePartPaymentVC
            vc.feeDetails = self.feeDetails
            vc.selectedInstallment = installment
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let installment = feeDetails.feeInstallments[indexPath.row]
        let isPaid = installment.feePaid >= installment.payableAmount
        
        if isPaid {
            return 150
        } else {
            return 200
        }
    }
}
