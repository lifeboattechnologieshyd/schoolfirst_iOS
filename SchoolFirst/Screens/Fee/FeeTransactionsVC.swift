//
//  FeeTransactionsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class FeeTransactionsVC: UIViewController {
    
    var feeDetails: StudentFeeDetails!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var allInstallments: [FeeInstallment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()

        print("Student Name: \(feeDetails.studentName)")
        
        // Show ALL installments (paid, partial, pending, failed - everything)
        allInstallments = feeDetails.feeInstallments.sorted { $0.installmentNo < $1.installmentNo }

        // Hide table if no installments
        tblVw.isHidden = allInstallments.isEmpty

        tblVw.register(
            UINib(nibName: "TransactionsCell", bundle: nil),
            forCellReuseIdentifier: "TransactionsCell"
        )

        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getPaymentStatus(for installment: FeeInstallment) -> (status: String, color: UIColor) {
        if installment.feePaid >= installment.payableAmount {
            // Fully Paid
            return ("Paid", UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)) // Green
        } else if installment.feePaid > 0 {
            // Partially Paid
            return ("Partial", UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)) // Orange
        } else {
            // Not Paid / Pending
            return ("Pending", UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)) // Red
        }
    }
}

extension FeeTransactionsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return allInstallments.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionsCell",
            for: indexPath
        ) as! TransactionsCell

        let installment = allInstallments[indexPath.row]

        // Format date
        let date = Date(timeIntervalSince1970: installment.dueDate / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        cell.dateLbl.text = formatter.string(from: date)

        // Show installment number
        cell.referencenoLbl.text = "Installment \(installment.installmentNo)"
        
        // Get payment status
        let (status, color) = getPaymentStatus(for: installment)
        cell.paymentMethodLbl.text = status
        cell.paymentMethodLbl.textColor = color
        
        // Show amount based on status
        if installment.feePaid >= installment.payableAmount {
            // Fully Paid - show paid amount
            cell.amountLbl.text = "₹\(Int(installment.feePaid))"
            cell.amountLbl.textColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0) // Green
        } else if installment.feePaid > 0 {
            // Partially Paid - show paid/total
            cell.amountLbl.text = "₹\(Int(installment.feePaid)) / ₹\(Int(installment.payableAmount))"
            cell.amountLbl.textColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Orange
        } else {
            // Pending - show payable amount
            cell.amountLbl.text = "₹\(Int(installment.payableAmount))"
            cell.amountLbl.textColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0) // Red
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
