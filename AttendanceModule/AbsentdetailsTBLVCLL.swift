//
//  AbsentdetailsTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

protocol AbsentdetailsTBLVCLLDelegate: AnyObject {
    func didTapAddLeaveNote()
}

class AbsentdetailsTBLVCLL: UITableViewCell {

    @IBOutlet weak var Addleavenotebutton: UIButton!
    @IBOutlet weak var ClasssectionandrollnumberLabel: UILabel!
    @IBOutlet weak var MarkedTeachernameLabel: UILabel!
    @IBOutlet weak var RemarksLabel: UILabel!
    @IBOutlet weak var Reason: UILabel!
    @IBOutlet weak var AbsentdateLabel: UILabel!
    @IBOutlet weak var Absentdate: UILabel!
    @IBOutlet weak var Attendancestatuslabel: UILabel!
    
    weak var delegate: AbsentdetailsTBLVCLLDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Existing XIB styling and layout remain unchanged.
        
        Addleavenotebutton.addTarget(self, action: #selector(didTapAddLeaveNoteButton), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc private func didTapAddLeaveNoteButton() {
        delegate?.didTapAddLeaveNote()
    }

    // MARK: - Configure Selected Attendance Details
    func configure(with record: FetchStudentAttendanceRecord?) {

        // Attendance status.
        let status = nonEmptyText(record?.status)

        Attendancestatuslabel.text = status?
            .replacingOccurrences(of: "_", with: " ")
            .capitalized ?? "—"

        // Both dates come from the selected attendance record,
        // not today's date or the record creation date.
        Absentdate.text = formattedDate(
            record?.attendanceDate,
            format: "dd MMM yyyy"
        )

        AbsentdateLabel.text = formattedDate(
            record?.attendanceDate,
            format: "EEEE, dd MMM yyyy"
        )

        // Class, section and admission number for the selected record.
        // Fallback to UserManager / DBManager if the API record is missing these details.
        let grade = nonEmptyText(record?.grade?.name) ?? nonEmptyText(UserManager.shared.resolvedStudentGrade) ?? "—"
        let section = nonEmptyText(record?.section?.name) ?? nonEmptyText(UserManager.shared.resolvedStudentSection) ?? "—"

        // Try from the API attendance record first
        let recordAdmission = nonEmptyText(record?.student?.admissionNumber)

        // Fallback: runtime-safe extraction from selectedKid (Student model)
        let dbAdmission = extractAdmissionNumber(from: UserManager.shared.selectedKid)

        // Last resort: UserDefaults
        let savedAdmission = nonEmptyText(
            UserDefaults.standard.string(forKey: "STUDENT_ADMISSION_NUMBER")
        )

        let admissionNumber = recordAdmission ?? dbAdmission ?? savedAdmission ?? "—"

        ClasssectionandrollnumberLabel.text =
            "\(grade) · \(section) "

        // Teacher who marked this particular record.
        MarkedTeachernameLabel.text = nonEmptyText(
            record?.markedBy?.name
        ) ?? "Not provided"

        // Actual remarks returned for this particular date.
        RemarksLabel.text = nonEmptyText(
            record?.remarks
        ) ?? "No remarks provided"

        // This API response has no separate absence reason field.
        Reason.text = "Not provided"
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

    // MARK: - Date Formatting
    private func formattedDate(
        _ dateString: String?,
        format: String
    ) -> String {

        guard let dateString = nonEmptyText(dateString) else {
            return "—"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
