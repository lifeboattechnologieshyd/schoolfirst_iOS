//
//  LeaverejectTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class LeaverejectTBLVCLL: UITableViewCell {

    @IBOutlet weak var BacktoleaverequestButton: UIButton!
    @IBOutlet weak var ClassandsectionandrollLabel: UILabel!
    @IBOutlet weak var DocumentattacherornotLabel: UILabel!
    @IBOutlet weak var RequestdaysLabel: UILabel!
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var RejecteddateLabel: UILabel!
    @IBOutlet weak var RejectreasonwithdateLabel: UILabel!
    
    /// Closure to trigger navigation to Apply Leave VC
    var onNavigateToApplyLeave: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        BacktoleaverequestButton.addTarget(self, action: #selector(didTapApplyLeaveButton), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc private func didTapApplyLeaveButton() {
        onNavigateToApplyLeave?()
    }
    
    // MARK: - Configure Data
    func configure(with item: LeaveListItem) {
        
        // 1. Class and Section and Roll
        let studentName = item.student.name
        let gradeSection = UserManager.shared.resolvedGradeSection.trimmingCharacters(in: .whitespacesAndNewlines)
        let admissionNum = item.student.admissionNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var parts: [String] = [studentName]
        if !gradeSection.isEmpty { parts.append(gradeSection) }
        if !admissionNum.isEmpty { parts.append("Roll \(admissionNum)") }
        ClassandsectionandrollLabel.text = parts.joined(separator: " · ")
        
        // 2. Document Attached
        let hasDoc = (item.pdf != nil && !item.pdf!.isEmpty)
        DocumentattacherornotLabel.text = hasDoc ? "Document attached" : "No document attached"
        
        // 3. Request Days (Date Range + Total Days)
        let startText = LeaveRejectVC.displayDate(from: item.startDate)
        let endText = LeaveRejectVC.displayDate(from: item.endDate)
        let rangeText = (startText == endText) ? startText : "\(startText) – \(endText)"
        
        let total = item.totalDays.trimmingCharacters(in: .whitespacesAndNewlines)
        let dayValue = Double(total) ?? 0
        let dayLabel = (dayValue == 1 || total == "1" || total == "1.0") ? "1 day" : "\(total) days"
        
        RequestdaysLabel.text = "\(rangeText) · \(dayLabel)"
        
        // 4. Reason
        let reasonStr = item.reason.trimmingCharacters(in: .whitespacesAndNewlines)
        ReasonLabel.text = reasonStr.isEmpty ? "—" : reasonStr
        
        // 5. Rejected Date
        let rejectedRaw = item.reviewedAt ?? item.createdAt
        let rejectedDisplay = LeaveRejectVC.displayDate(from: rejectedRaw)
        RejecteddateLabel.text = rejectedDisplay
        
        // 6. Reject Reason with Date
        let rejectReason = (item.reviewRemarks ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if rejectReason.isEmpty {
            RejectreasonwithdateLabel.text = "Rejected on \(rejectedDisplay)"
        } else {
            RejectreasonwithdateLabel.text = "\(rejectReason) · \(rejectedDisplay)"
        }
    }
}
