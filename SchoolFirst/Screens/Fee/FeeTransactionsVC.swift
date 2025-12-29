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
    
    var paidInstallments: [FeeInstallment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()

        print(feeDetails.studentName)
        
        // Filter installments where some payment is done
        paidInstallments = feeDetails.feeInstallments.filter { $0.feePaid > 0 }

        // Hide table if no transactions
        tblVw.isHidden = paidInstallments.isEmpty

        tblVw.register(
            UINib(nibName: "TransactionsCell", bundle: nil),
            forCellReuseIdentifier: "TransactionsCell"
        )

        tblVw.delegate = self
        tblVw.dataSource = self
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FeeTransactionsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return paidInstallments.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionsCell",
            for: indexPath
        ) as! TransactionsCell

        let installment = paidInstallments[indexPath.row]

        let date = Date(timeIntervalSince1970: installment.dueDate / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        cell.dateLbl.text = formatter.string(from: date)

        cell.amountLbl.text = "₹\(installment.feePaid)"
        cell.referencenoLbl.text = "Installment \(installment.installmentNo)"
        cell.paymentMethodLbl.text = "Paid"

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
