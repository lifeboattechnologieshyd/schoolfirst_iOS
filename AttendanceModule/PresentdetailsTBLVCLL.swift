//
//  PresentdetailsTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class PresentdetailsTBLVCLL: UITableViewCell {

    @IBOutlet weak var VieweaklyattendanceButton: UIButton!
    @IBOutlet weak var StudentnameLabel: UILabel!
    @IBOutlet weak var Remarkslabel: UILabel!
    @IBOutlet weak var Classsectionandadmissionlabel: UILabel!
    @IBOutlet weak var MarkedTeachernameLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var CheckedinontimewithDatelabel: UILabel!
    @IBOutlet weak var PresentdateLabel: UILabel!

    /// Called when VieweaklyattendanceButton is tapped
    var onWeeklyAttendanceTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Existing XIB styling and layout remain unchanged.

        VieweaklyattendanceButton?.addTarget(
            self,
            action: #selector(didTapWeeklyAttendance),
            for: .touchUpInside
        )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @objc private func didTapWeeklyAttendance() {
        onWeeklyAttendanceTapped?()
    }

    // MARK: - Configure Selected Present Attendance
    func configure(with record: FetchStudentAttendanceRecord?) {

        // Student name with the requested sentence. Fallback to UserManager if record is nil.
        let studentName = nonEmptyText(record?.student?.name) ?? nonEmptyText(UserManager.shared.resolvedStudentName) ?? "The student"

        StudentnameLabel.text =
            "\(studentName) was marked present for the full day."

        // Use the selected attendance date, not createdAt or today's date.
        let shortDate = formattedDate(
            record?.attendanceDate,
            format: "dd MMM yyyy"
        )

        let fullDate = formattedDate(
            record?.attendanceDate,
            format: "EEEE, dd MMM yyyy"
        )

        DateLabel.text = shortDate
        PresentdateLabel.text = fullDate

        // The response supplies status and date, but no check-in time.
        let statusText = (nonEmptyText(record?.status) ?? "—")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized

        CheckedinontimewithDatelabel.text =
            "\(statusText) · \(shortDate)"

        // Remarks for this attendance record.
        Remarkslabel.text = nonEmptyText(
            record?.remarks
        ) ?? "No remarks provided"

        // Teacher who marked this attendance record.
        MarkedTeachernameLabel.text = nonEmptyText(
            record?.markedBy?.name
        ) ?? "Not provided"

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

        Classsectionandadmissionlabel.text =
            "\(grade) · \(section) ·"
    }

    // MARK: - Runtime-safe Admission Number Extractor from Student
    /// Reads the admission number field from Student model WITHOUT compile-time dependency.
    /// Works whatever the property is named: admissionNumber, admission_number, rollNumber, roll_number, etc.
    private func extractAdmissionNumber(from student: Student?) -> String? {
        guard let student = student else { return nil }

        let candidateKeys = [
            "admissionNumber", "admission_number", "admission_no",
            "admissionNo", "admission_no",
            "rollNumber", "roll_number", "rollNo", "roll_no",
            "registerNumber", "register_number",
            "studentNumber", "student_number",
            "admissionId", "admission_id"
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
