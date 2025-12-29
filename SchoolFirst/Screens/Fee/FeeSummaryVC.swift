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

        studentNameLbl.text = feeDetails.studentName
        gradeLbl.text = feeDetails.gradeName
        studentImg.loadImage(url: feeDetails.studentImage ?? "")

        annualAmountLbl.text = "₹\(feeDetails.totalFee)"
        paidAmountLbl.text = "₹\(feeDetails.feePaid)"
        balanceAmountLbl.text = "₹\(feeDetails.pendingFee)"

        let progress = Float(feeDetails.feePaid / feeDetails.totalFee)
        progressVw.progress = progress

        tblVw.register(
            UINib(nibName: "FeeSummaryCell", bundle: nil),
            forCellReuseIdentifier: "FeeSummaryCell"
        )

        tblVw.delegate = self
        tblVw.dataSource = self
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
    
    func showSuccessAlert(orderId: String) {
        let alert = UIAlertController(
            title: "Payment Successful! 🎉",
            message: "Order ID: \(orderId)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Refresh data or pop
            self.navigationController?.popViewController(animated: true)
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
        
        // Pay Full Button Tap
        cell.onPayFull = { [weak self] in
            guard let self = self else { return }
            
            let pendingAmount = installment.payableAmount - installment.feePaid
            
            PaymentHelper.shared.startPayment(
                studentFeeId: self.feeDetails.studentFeeID,
                installmentNumber: installment.installmentNo,
                amount: pendingAmount,
                from: self,
                onSuccess: { orderId in
                    self.showSuccessAlert(orderId: orderId)
                },
                onFailure: { error in
                    self.showAlert(msg: error)
                }
            )
        }
        
        // Part Payment Button Tap
        cell.onPartPayment = { [weak self] in
            guard let self = self else { return }
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "FeePartPaymentVC") as! FeePartPaymentVC
            vc.feeDetails = self.feeDetails
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}
