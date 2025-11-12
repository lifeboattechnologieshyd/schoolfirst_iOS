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
    
    @IBOutlet weak var lblDueDate: UILabel!
    
    @IBOutlet weak var lblInstallment: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickPartPayment(_ sender: UIButton) {
    }
    
    
    @IBAction func onClickPayFull(_ sender: UIButton) {
    }
    
    
    func setup(details : StudentFeeDetails) {
        self.lblName.text = details.studentName
        self.lblGrade.text = details.gradeName
        self.imgVw.loadImage(url: details.studentImage)
        self.lblTotalFeeDue.text = "₹\(details.pendingFee.rounded())"
    }
    
    
}
