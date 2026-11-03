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
        
        // 1. Class, Section and Roll with fallback chain
        //    (same pattern as PresentdetailsTBLVCLL)
        let grade = nonEmptyText(UserManager.shared.resolvedStudentGrade) ?? "—"
        let section = nonEmptyText(UserManager.shared.resolvedStudentSection) ?? "—"

        // Try runtime-safe extraction from selectedKid
        let dbAdmission = extractAdmissionNumber(from: UserManager.shared.selectedKid)

        // Last resort: UserDefaults
        let savedAdmission = nonEmptyText(
            UserDefaults.standard.string(forKey: "STUDENT_ADMISSION_NUMBER")
        )

        let admissionNumber = dbAdmission ?? savedAdmission ?? "—"

        ClassandsectionandrollLabel.text =
            "\(grade) · \(section) "
        
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

    // MARK: - Runtime-safe Admission Number Extractor from Student
    /// Reads the admission number field from Student model WITHOUT compile-time dependency.
    /// Works whatever the property is named: admissionNumber, admission_number, rollNumber, roll_number, etc.
    private func extractAdmissionNumber(from student: Student?) -> String? {
        guard let student = student else { return nil }

        let candidateKeys = [
            "admissionNumber", "admission_number", "admission_no",
            "admissionNo", "admission_id", "admissionId",
            "rollNumber", "roll_number", "rollNo", "roll_no",
            "registerNumber", "register_number",
            "studentNumber", "student_number"
        ]

        let mirror = Mirror(reflecting: student)
        for child in mirror.children {
            guard let label = child.label, candidateKeys.contains(label) else { continue }

            if let str = child.value as? String, !str.isEmpty {
                return str
            }
            if let optionalStr = child.value as? String?, let str = optionalStr, !str.isEmpty {
                return str
            }
            if let intVal = child.value as? Int {
                return String(intVal)
            }
            if let optInt = child.value as? Int?, let intVal = optInt {
                return String(intVal)
            }
        }
        return nil
    }

    // MARK: - Handle Missing or Empty Values
    private func nonEmptyText(_ value: String?) -> String? {
        guard let text = value?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        return text
    }
}
