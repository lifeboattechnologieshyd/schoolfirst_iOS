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
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var partpaymentBtn: UIButton!
    
    @IBOutlet weak var studentnameLbl: UILabel!
    @IBOutlet weak var totalfeedueLbl: UILabel!
    @IBOutlet weak var dueDate: UIButton!
    @IBOutlet weak var fineamountLbl: UILabel!
    @IBOutlet weak var fineLbl: UILabel!
    @IBOutlet weak var installmentsNoLbl: UILabel!
    @IBOutlet weak var feedue: UILabel!
    @IBOutlet weak var remainderLbl: UILabel!
    
    var onPartPayment: (() -> Void)?
    var onPayFull: (() -> Void)?
    var onDueDate: (() -> Void)?
    var onViewSummary: (() -> Void)?
    
    private let defaultStudentImage = "userImage"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgVw.image = UIImage(named: defaultStudentImage)
        lblName.text = nil
        lblGrade.text = nil
        studentnameLbl.text = nil
        totalfeedueLbl.text = nil
        fineamountLbl.text = nil
        feedue.text = nil
        installmentsNoLbl.text = nil
        remainderLbl.text = nil
        fineLbl.text = nil
        dueDate.setTitle(nil, for: .normal)
        
        onPartPayment = nil
        onPayFull = nil
        onDueDate = nil
        onViewSummary = nil
    }
    
    private func setupUI() {
        imgVw.layer.cornerRadius = imgVw.frame.height / 2
        imgVw.clipsToBounds = true
        imgVw.contentMode = .scaleAspectFill
        imgVw.image = UIImage(named: defaultStudentImage)
        
        payfullBtn.layer.cornerRadius = 8
        partpaymentBtn.layer.cornerRadius = 8
        viewSummary.layer.cornerRadius = 8
        
        remainderLbl.numberOfLines = 0
        remainderLbl.lineBreakMode = .byWordWrapping
    }
    
    @IBAction func onClickPartPayment(_ sender: UIButton) {
        onPartPayment?()
    }
    
    @IBAction func onClickPayFull(_ sender: UIButton) {
        onPayFull?()
    }
    
    @IBAction func onClickViewSummary(_ sender: UIButton) {
        onViewSummary?()
    }
    
    func setup(details: StudentFeeDetails) {
        lblName.text = details.studentName
        lblGrade.text = details.gradeName
        studentnameLbl.text = details.studentName
        
        loadStudentImage(urlString: details.studentImage)
        setupFeeDetails(details: details)
        setupDueDate(details: details)
        setupRemainderMessage(details: details)
        setupDynamicFineLabel(details: details)
    }
    
    private func setupFeeDetails(details: StudentFeeDetails) {
        let feeDue = details.pendingFee
        let fine = details.finePayable
        let totalDue = feeDue + fine
        
        feedue.text = "₹\(formatAmount(feeDue))"
        fineamountLbl.text = "₹\(formatAmount(fine))"
        totalfeedueLbl.text = "₹\(formatAmount(totalDue))"
        
        let totalInstallments = details.feeInstallments.count
        let installmentNumbers = (1...totalInstallments)
            .map { String($0) }
            .joined(separator: ", ")
        
        installmentsNoLbl.text = installmentNumbers
    }
    
    private func setupDynamicFineLabel(details: StudentFeeDetails) {
        let sortedInstallments = details.feeInstallments.sorted { $0.installmentNo < $1.installmentNo }
        
        guard let unpaidInstallment = sortedInstallments.first(where: { !$0.isPaid }) else {
            fineLbl.text = "Fine"
            fineLbl.textColor = .darkGray
            return
        }
        
        if unpaidInstallment.hasFine {
            fineLbl.text = unpaidInstallment.fineDisplayText
            fineLbl.textColor = .systemRed
        } else {
            fineLbl.text = "Fine"
            fineLbl.textColor = .darkGray
        }
    }
    
    private func setupDueDate(details: StudentFeeDetails) {
        let sortedInstallments = details.feeInstallments.sorted { $0.installmentNo < $1.installmentNo }
        
        if let nextInstallment = sortedInstallments.first(where: { !$0.isPaid }) {
            dueDate.setTitle(nextInstallment.dueDateFormatted(), for: .normal)
        } else {
            dueDate.setTitle("All Paid", for: .normal)
        }
        
        dueDate.titleLabel?.font = UIFont.lexend(.semiBold, size: 16)
    }
    
    private func setupRemainderMessage(details: StudentFeeDetails) {
        let sortedInstallments = details.feeInstallments.sorted { $0.installmentNo < $1.installmentNo }
        
        guard let nextInstallment = sortedInstallments.first(where: { !$0.isPaid }) else {
            remainderLbl.text = "All fees are paid! ✅"
            remainderLbl.textColor = .systemGreen
            return
        }
        
        let daysRemaining = nextInstallment.daysUntilDue
        let finePerDay = nextInstallment.calculatedFinePerDay
        
        if daysRemaining < 0 {
            let daysPassed = abs(daysRemaining)
            if finePerDay > 0 {
                remainderLbl.text = "Due date passed \(daysPassed) day(s) ago. Please Pay the Fee immediately to avoid Late Fee Fine of ₹\(formatAmount(finePerDay)) per day"
            } else {
                remainderLbl.text = "Due date passed \(daysPassed) day(s) ago. Please Pay the Fee immediately."
            }
            remainderLbl.textColor = .systemRed
        } else if daysRemaining == 0 {
            remainderLbl.text = "Payment is due TODAY! Pay now to avoid fine."
            remainderLbl.textColor = .systemOrange
        } else if daysRemaining <= 7 {
            remainderLbl.text = "Only \(daysRemaining) Day(s) remaining. Pay Now to avoid Fine"
            remainderLbl.textColor = .systemOrange
        } else {
            remainderLbl.text = "Next payment due in \(daysRemaining) days"
            remainderLbl.textColor = .darkGray
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount == amount.rounded() {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.2f", amount)
        }
    }
    
    private func loadStudentImage(urlString: String?) {
        guard let urlString = urlString, !urlString.isEmpty else {
            imgVw.image = UIImage(named: defaultStudentImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            imgVw.image = UIImage(named: defaultStudentImage)
            return
        }
        
        imgVw.image = UIImage(named: defaultStudentImage)
        
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
}
