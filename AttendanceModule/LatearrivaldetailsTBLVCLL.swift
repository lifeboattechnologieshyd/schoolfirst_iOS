//
//  LatearrivaldetailsTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class LatearrivaldetailsTBLVCLL: UITableViewCell {

    @IBOutlet weak var AddnotefortheschoolButton: UIButton!
    
    @IBOutlet weak var LatetimeLabel: UILabel!
    @IBOutlet weak var LatedateLabel: UILabel!
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var MarkedteachernameLabel: UILabel!
    @IBOutlet weak var LatetimeLabel2: UILabel!
    @IBOutlet weak var Classsectionandrollnumberlabel: UILabel!

    @IBOutlet weak var LatereasonwithdateLabel: UILabel!
    @IBOutlet weak var LatearrivaldateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Existing XIB styling and layout remain unchanged.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure Selected Late Attendance
    func configure(with record: FetchStudentAttendanceRecord?) {

        let shortDate = formattedDate(
            record?.attendanceDate,
            format: "dd MMM yyyy"
        )

        let fullDate = formattedDate(
            record?.attendanceDate,
            format: "EEEE, dd MMM yyyy"
        )

        // Date belonging to the tapped attendance record.
        LatedateLabel.text = shortDate
        LatearrivaldateLabel.text = fullDate

        // The supplied model has no arrival time or late duration.
        // Do not use createdAt as the student's arrival time.
        LatetimeLabel.text = "—"
        LatetimeLabel2.text = "—"

        // Display the API remarks in the reason outlets.
        let remarks = nonEmptyText(record?.remarks) ?? "Not provided"

        ReasonLabel.text = remarks
        LatereasonwithdateLabel.text = "\(shortDate) · \(remarks)"

        // Teacher who marked this particular attendance record.
        MarkedteachernameLabel.text = nonEmptyText(
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

        // The API supplies an admission number, not a roll number.
        Classsectionandrollnumberlabel.text =
            "\(grade) · \(section) "
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
