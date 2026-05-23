//
//  LeaveHistoryCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 05/01/26.
//

import UIKit

class LeaveHistoryCell: UITableViewCell {
    
    @IBOutlet weak var noofdaysLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusVw: UIView!
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var resubmitBtn: UIButton!
    @IBOutlet weak var remarksLbl: UILabel!
    @IBOutlet weak var leaveDate: UILabel!
    
    private var remarksHeightConstraint: NSLayoutConstraint?
    private var resubmitHeightConstraint: NSLayoutConstraint?
    
    // Store original heights
    private var originalResubmitBtnHeight: CGFloat = 32
    private var originalRemarksHeight: CGFloat = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgVw.addCardShadow()
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Store original heights before adding constraints
        originalResubmitBtnHeight = resubmitBtn.frame.height > 0 ? resubmitBtn.frame.height : 32
        originalRemarksHeight = remarksLbl.frame.height > 0 ? remarksLbl.frame.height : 15
        
        // Create height constraint for remarksLbl if not exists
        remarksLbl.translatesAutoresizingMaskIntoConstraints = false
        remarksHeightConstraint = remarksLbl.heightAnchor.constraint(greaterThanOrEqualToConstant: originalRemarksHeight)
        remarksHeightConstraint?.priority = .defaultHigh
        remarksHeightConstraint?.isActive = true
        
        // Create height constraint for resubmitBtn if not exists
        resubmitBtn.translatesAutoresizingMaskIntoConstraints = false
        resubmitHeightConstraint = resubmitBtn.heightAnchor.constraint(equalToConstant: originalResubmitBtnHeight)
        resubmitHeightConstraint?.isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset to original values
        remarksLbl.isHidden = false
        resubmitBtn.isHidden = false
        remarksHeightConstraint?.constant = originalRemarksHeight
        resubmitHeightConstraint?.constant = originalResubmitBtnHeight
    }
    
    func configure(with leave: LeaveHistoryData) {
        // Set date range
        leaveDate.text = leave.formattedDateRange
        
        // Set number of days
        noofdaysLbl.text = leave.formattedTotalDays
        
        // Set reason
        if leave.reason.isEmpty {
            reasonLbl.text = "Reason: \(leave.reasonType)"
        } else {
            reasonLbl.text = "Reason: \(leave.reason)"
        }
        
        // Set status
        statusLbl.text = leave.leaveStatus
        
        // Set status color and resubmit button visibility
        switch leave.leaveStatus.lowercased() {
        case "approved":
            statusVw.backgroundColor = UIColor(hex: "#CFEFD0")
            hideResubmitButton()
            
        case "rejected":
            statusVw.backgroundColor = UIColor(hex: "#FFCCD1")
            showResubmitButton()
            
        case "pending":
            statusVw.backgroundColor = UIColor(hex: "#FDE7CC")
            hideResubmitButton()
            
        default:
            statusVw.backgroundColor = .gray
            hideResubmitButton()
        }
        
        // Set teacher remarks
        if let remarks = leave.teacherRemarks, !remarks.isEmpty {
            remarksLbl.text = "Remarks: \(remarks)"
            showRemarksLabel()
        } else {
            hideRemarksLabel()
        }
        
        // Force layout update
        self.layoutIfNeeded()
    }
    
    private func hideResubmitButton() {
        resubmitBtn.isHidden = true
        resubmitHeightConstraint?.constant = 0
    }
    
    private func showResubmitButton() {
        resubmitBtn.isHidden = false
        resubmitHeightConstraint?.constant = originalResubmitBtnHeight
    }
    
    private func hideRemarksLabel() {
        remarksLbl.isHidden = true
        remarksLbl.text = nil
    }
    
    private func showRemarksLabel() {
        remarksLbl.isHidden = false
    }
}
