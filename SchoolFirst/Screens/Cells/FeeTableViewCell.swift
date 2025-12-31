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
    
    //DEFAULT IMAGE NAME - Change this to your image name in Assets.xcassets
    private let defaultStudentImage = "userImage"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset cell data to avoid flickering
        imgVw.image = UIImage(named: defaultStudentImage)
        lblName.text = nil
        lblGrade.text = nil
        lblTotalFeeDue.text = nil
        lblInstallment.text = nil
        DueDate.setTitle(nil, for: .normal)
        
        // Reset closures
        onPartPayment = nil
        onPayFull = nil
        onDueDate = nil
        onViewSummary = nil
    }
    
    private func setupUI() {
        // Make image view circular
        imgVw.layer.cornerRadius = imgVw.frame.height / 2
        imgVw.clipsToBounds = true
        imgVw.contentMode = .scaleAspectFill
        imgVw.image = UIImage(named: defaultStudentImage)
        
        // Background view styling
        bgView.layer.cornerRadius = 12
        bgView.clipsToBounds = true
        
        // Button styling
        payfullBtn.layer.cornerRadius = 8
        partpaymentBtn.layer.cornerRadius = 8
        viewSummary.layer.cornerRadius = 8
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
    
    func setup(details: StudentFeeDetails) {
        // Set name and grade
        lblName.text = details.studentName
        lblGrade.text = details.gradeName
        
        // ✅ Handle null/empty image with default placeholder
        loadStudentImage(urlString: details.studentImage)
        
        // Set total fee due
        lblTotalFeeDue.text = "₹\(details.pendingFee.rounded())"
        
        // Set installment numbers
        let installmentNumbers = details.feeInstallments
            .map { String($0.installmentNo) }
            .joined(separator: ", ")
        lblInstallment.text = installmentNumbers.isEmpty ? "N/A" : installmentNumbers
        
        // Set due date
        setupDueDate(details: details)
    }
    
    private func loadStudentImage(urlString: String?) {
        // ✅ Check if image URL is nil or empty
        guard let urlString = urlString, !urlString.isEmpty else {
            imgVw.image = UIImage(named: defaultStudentImage)
            return
        }
        
        // ✅ Check if URL is valid
        guard let url = URL(string: urlString) else {
            imgVw.image = UIImage(named: defaultStudentImage)
            return
        }
        
        // Set placeholder first
        imgVw.image = UIImage(named: defaultStudentImage)
        
        // ✅ Load image using URLSession directly
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.imgVw.image = image
            }
        }.resume()
    }
    
    private func setupDueDate(details: StudentFeeDetails) {
        let sortedInstallments = details.feeInstallments.sorted { $0.installmentNo < $1.installmentNo }
        
        if let nextInstallment = sortedInstallments.first(where: { $0.feePaid < $0.payableAmount }) {
            let date = Date(timeIntervalSince1970: nextInstallment.dueDate / 1000)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            DueDate.setTitle(formatter.string(from: date), for: .normal)
        } else {
            DueDate.setTitle("All Paid", for: .normal)
        }
    }
}
