//
//  FeeTableViewCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/09/25.
//

import UIKit

class FeeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewSummary: UIButton!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var payfullBtn: UIButton!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var partpaymentBtn: UIButton!
    
    @IBOutlet weak var lblTotalFeeDue: UILabel!
    @IBOutlet weak var DueDate: UIButton!
    @IBOutlet weak var lblInstallment: UILabel!
    
    var onPartPayment: (() -> Void)?
    var onPayFull: (() -> Void)?
    var onDueDate: (() -> Void)?
    var onViewSummary: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onClickPartPayment(_ sender: UIButton) {
        onPartPayment?()
    }
    
    @IBAction func onClickPayFull(_ sender: UIButton) {
        onPayFull?()
    }
    
    @IBAction func onClickDueDate(_ sender: UIButton) {
        onDueDate?()
    }
    @IBAction func onClickViewSummary(_ sender: UIButton) {
        onViewSummary?()
    }
    
    
    func setup(details : StudentFeeDetails) {
        self.lblName.text = details.studentName
        self.lblGrade.text = details.gradeName
        self.imgVw.loadImage(url: details.studentImage ?? "")
        self.lblTotalFeeDue.text = "₹\(details.pendingFee.rounded())"
        
        let installmentNumbers = details.feeInstallments
            .map { String($0.installmentNo) }
            .joined(separator: ", ")

        lblInstallment.text = installmentNumbers

        //        if let nextInstallment = details.feeInstallments.first(where: { $0.feePaid < $0.payableAmount }) {
        //                // Divide by 1000 if API gives milliseconds
        //                let date = Date(timeIntervalSince1970: nextInstallment.dueDate / 1000)
        //                let formatter = DateFormatter()
        //                formatter.dateFormat = "dd MMM yyyy"
        //            DueDate.text = formatter.string(from: date)
        //            } else {
        //                DueDate.text = "All Paid"
        //            }
        //        }
        //}
    }
    }
