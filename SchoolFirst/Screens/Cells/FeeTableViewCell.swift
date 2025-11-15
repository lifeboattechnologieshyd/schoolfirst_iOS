//
//  FeeTableViewCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/09/25.
//

import UIKit

class FeeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var lblTotalFeeDue: UILabel!
    @IBOutlet weak var DueDate: UIButton!
    @IBOutlet weak var lblInstallment: UILabel!
    
    var onClickPartPayment: (() -> Void)?
    var onClickPayFull: (() -> Void)?
    var onClickDueDate: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func onClickPartPayment(_ sender: UIButton) {
        onClickPartPayment?()
    }
    
    @IBAction func onClickPayFull(_ sender: UIButton) {
        onClickPayFull?()
    }

    @IBAction func onClickDueDate(_ sender: UIButton) {
        onClickDueDate?()      // ⭐ trigger navigation
    }
    
    func setup(details : StudentFeeDetails) {
        self.lblName.text = details.studentName
        self.lblGrade.text = details.gradeName
        self.imgVw.loadImage(url: details.studentImage)
        self.lblTotalFeeDue.text = "₹\(details.pendingFee.rounded())"
    }
}
