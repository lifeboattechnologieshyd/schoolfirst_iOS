//
//  FeeSummaryCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//
import UIKit

class FeeSummaryCell: UITableViewCell {

    @IBOutlet weak var installmentVw: UIView!
    @IBOutlet weak var dueamount: UILabel!
    @IBOutlet weak var dueLbl: UILabel!
    @IBOutlet weak var paidAmountLbl: UILabel!
    @IBOutlet weak var dueMonth: UIButton!
    @IBOutlet weak var installmentVw1: UIView!
    @IBOutlet weak var buttonsContainer1: UIView!
    @IBOutlet weak var partPaymentBtn1: UIButton!
    @IBOutlet weak var payFullBtn1: UIButton!
    
    var onPayFull: (() -> Void)?
    var onPartPayment: (() -> Void)?
   
    var isFirstTap = true

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonsContainer1.isHidden = true
          
        installmentVw1.addCardShadow()
        installmentVw.addCardShadow()

        installmentVw1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle1)))
    }

    private func closeAll() {
        buttonsContainer1.isHidden = true
    }

    @objc func toggle1() {
        let willOpen = buttonsContainer1.isHidden
        closeAll()
        buttonsContainer1.isHidden = !willOpen
        UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
    }
    
    @IBAction func onClickPayFull(_ sender: UIButton) {
        onPayFull?()
    }
    
    @IBAction func onClickPartPayment(_ sender: UIButton) {
        onPartPayment?()
    }

    @IBAction func onClickdueMonth(_ sender: UIButton) {
        let red = UIColor(red: 0xEE/255, green: 0x4E/255 , blue: 0x4E/255, alpha: 1)

        let currentTitle = dueMonth.titleLabel?.text ?? ""

        let attributed = NSAttributedString(
            string: currentTitle,
            attributes: [
                .foregroundColor: red,
            ]
        )
        
        dueMonth.setAttributedTitle(attributed, for: .normal)

        if isFirstTap {
            dueLbl.text = "Only 2 Days remaining"
            dueLbl.textColor = red
        } else {
            dueLbl.text = "Fine: ₹100 * 4 Days"
            dueLbl.textColor = red
            dueamount.text = "₹35,400"
        }

        isFirstTap.toggle()
    }
    
    func configure(with installment: FeeInstallment, feeDetails: StudentFeeDetails) {
        dueMonth.setTitle(installment.dueDate.toMonthYear(), for: .normal)
        dueamount.text = "₹\(installment.payableAmount)"

        if installment.fineDays > 0 {
            dueLbl.text = "Fine: ₹\(installment.finePerDay) × \(installment.fineDays) Days"
        } else {
            dueLbl.text = "Due Amount"
        }
        
        paidAmountLbl.text = "Paid: ₹\(installment.feePaid)"
    }
}
