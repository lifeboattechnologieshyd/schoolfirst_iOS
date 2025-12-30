//
//  FeeSummaryCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class FeeSummaryCell: UITableViewCell {

     @IBOutlet weak var installmentVw: UIView!
    @IBOutlet weak var installmentVwHeight: NSLayoutConstraint!  // ← ADD THIS
    @IBOutlet weak var dueamount: UILabel!
    @IBOutlet weak var dueLbl: UILabel!
    @IBOutlet weak var paidAmountLbl: UILabel!
    @IBOutlet weak var dueMonth: UIButton!
    
    @IBOutlet weak var installmentVw1: UIView!
    @IBOutlet weak var installmentVw1Height: NSLayoutConstraint! // ← ADD THIS
    @IBOutlet weak var dueMonth1: UIButton!
    @IBOutlet weak var dueamount1: UILabel!
    @IBOutlet weak var dueLbl1: UILabel!
    @IBOutlet weak var paidAmountLbl1: UILabel!
    @IBOutlet weak var buttonsContainer1: UIView!
    @IBOutlet weak var partPaymentBtn1: UIButton!
    @IBOutlet weak var payFullBtn1: UIButton!
    
       private let viewHeight: CGFloat = 150  // Your view height
    
    var onPayFull: (() -> Void)?
    var onPartPayment: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonsContainer1.isHidden = true
        installmentVw.addCardShadow()
        installmentVw1.addCardShadow()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleButtons))
        installmentVw1.addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset all states
        buttonsContainer1.isHidden = true
        installmentVw.isHidden = false
        installmentVw1.isHidden = false
        installmentVwHeight.constant = viewHeight
        installmentVw1Height.constant = viewHeight
    }
    
    @objc func toggleButtons() {
        buttonsContainer1.isHidden.toggle()
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func onClickPayFull(_ sender: UIButton) {
        onPayFull?()
    }
    
    @IBAction func onClickPartPayment(_ sender: UIButton) {
        onPartPayment?()
    }
    func configure(with installment: FeeInstallment, feeDetails: StudentFeeDetails) {
        
        // Check if installment is FULLY PAID
        let isPaid = installment.feePaid >= installment.payableAmount
        
        if isPaid {
             showPaidView()
            hidePendingView()
            
            // Configure PAID view labels
            dueMonth.setTitle(installment.dueDate.toMonthYear(), for: .normal)
            dueMonth.setTitleColor(UIColor(hex: "#4CAF50"), for: .normal)
            
            dueamount.text = "₹\(installment.payableAmount)"
            paidAmountLbl.text = "Paid: ₹\(installment.feePaid)"
            
            dueLbl.text = "✓ Paid"
            dueLbl.textColor = UIColor(hex: "#4CAF50")
            
        } else {
         
            hidePaidView()
            showPendingView()
            
            // Configure PENDING view labels
            dueMonth1.setTitle(installment.dueDate.toMonthYear(), for: .normal)
            dueamount1.text = "₹\(installment.payableAmount)"
            
            if installment.feePaid > 0 {
                paidAmountLbl1.text = "Paid: ₹\(installment.feePaid)"
                paidAmountLbl1.isHidden = false
            } else {
                paidAmountLbl1.isHidden = true
            }
            
            if installment.fineDays > 0 {
                dueLbl1.text = "Fine: ₹\(installment.finePerDay) × \(installment.fineDays) Days"
                dueLbl1.textColor = UIColor(hex: "#EE4E4E")
                dueMonth1.setTitleColor(UIColor(hex: "#EE4E4E"), for: .normal)
            } else {
                dueLbl1.text = "Due Amount"
                dueLbl1.textColor = .darkGray
                dueMonth1.setTitleColor(.darkGray, for: .normal)
            }
        }
    }
    
      private func showPaidView() {
        installmentVw.isHidden = false
        installmentVwHeight.constant = viewHeight
    }
    
    private func hidePaidView() {
        installmentVw.isHidden = true
        installmentVwHeight.constant = 0  // ← No gap!
    }
    
    private func showPendingView() {
        installmentVw1.isHidden = false
        installmentVw1Height.constant = viewHeight
    }
    
    private func hidePendingView() {
        installmentVw1.isHidden = true
        installmentVw1Height.constant = 0  // ← No gap!
    }
}
