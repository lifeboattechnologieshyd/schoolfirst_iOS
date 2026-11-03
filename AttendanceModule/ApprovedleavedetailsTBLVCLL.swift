//
//  ApprovedleavedetailsTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

class ApprovedleavedetailsTBLVCLL: UITableViewCell {

    @IBOutlet weak var ClassandsectionLabel: UILabel!
    @IBOutlet weak var DocumentattachedornotLabel: UILabel!
    @IBOutlet weak var NumberofdaysLabel: UILabel!
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var LeavedateLabel: UILabel!
    @IBOutlet weak var LeavereasonanddateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Configure
    func configure(with leave: LeaveListItem) {
        
        // Class, section and admission number with fallback chain
        // (same pattern as PresentdetailsTBLVCLL)
        let grade = nonEmptyText(UserManager.shared.resolvedStudentGrade) ?? "—"
        let section = nonEmptyText(UserManager.shared.resolvedStudentSection) ?? "—"

        // Try runtime-safe extraction from selectedKid
        let dbAdmission = extractAdmissionNumber(from: UserManager.shared.selectedKid)

        // Last resort: UserDefaults
        let savedAdmission = nonEmptyText(
            UserDefaults.standard.string(forKey: "STUDENT_ADMISSION_NUMBER")
        )

        let admissionNumber = dbAdmission ?? savedAdmission ?? "—"

        ClassandsectionLabel.text =
            "\(grade) · \(section) "
        
        // Document Attached or Not
        if let pdf = leave.pdf,
           !pdf.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DocumentattachedornotLabel.text = "Document attached"
        } else {
            DocumentattachedornotLabel.text = "No document attached"
        }
        
        // Number of Days
        NumberofdaysLabel.text = formattedDays(leave.totalDays)
        
        // Reason
        let reasonText = leave.reason.trimmingCharacters(in: .whitespacesAndNewlines)
        if !reasonText.isEmpty {
            ReasonLabel.text = reasonText
        } else {
            ReasonLabel.text = displayLeaveType(leave.leaveType)
        }
        
        // Leave Date
        LeavedateLabel.text = compactDateText(start: leave.startDate, end: leave.endDate)
        
        // Leave Reason and Date Label (Header)
        let reasonHeaderText = leave.reason.trimmingCharacters(in: .whitespacesAndNewlines)
        if !reasonHeaderText.isEmpty {
            LeavereasonanddateLabel.text = reasonHeaderText
        } else {
            LeavereasonanddateLabel.text = displayLeaveType(leave.leaveType)
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
    
    // MARK: - Helpers
    private func displayLeaveType(_ raw: String) -> String {
        switch raw.uppercased() {
        case "SICK":
            return "Sick Leave"
        case "CASUAL":
            return "Casual Leave"
        case "EMERGENCY":
            return "Emergency Leave"
        case "OTHER":
            return "Other Leave"
        default:
            return raw.capitalized
        }
    }
    
    private func formattedDays(_ value: String) -> String {
        guard let days = Double(value) else {
            return "\(value) days"
        }
        
        if days == 1 {
            return "1 day"
        }
        
        if days.rounded() == days {
            return "\(Int(days)) days"
        }
        
        return "\(days) days"
    }
    
    private func compactDateText(start: String, end: String) -> String {
        guard
            let startDate = Self.apiDateFormatter.date(from: start),
            let endDate = Self.apiDateFormatter.date(from: end)
        else {
            return start == end ? start : "\(start) - \(end)"
        }
        
        if startDate == endDate {
            return Self.compactDateFormatter.string(from: startDate)
        }
        
        let startText = Self.compactDateFormatter.string(from: startDate)
        let endText = Self.compactDateFormatter.string(from: endDate)
        
        return "\(startText) - \(endText)"
    }
    
    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let compactDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
