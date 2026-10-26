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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Existing XIB styling and layout remain unchanged.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure Selected Present Attendance
    func configure(with record: FetchStudentAttendanceRecord?) {

        // Student name with the requested sentence.
        let studentName = nonEmptyText(record?.student?.name) ?? "The student"

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
        let grade = nonEmptyText(record?.grade?.name) ?? "—"
        let section = nonEmptyText(record?.section?.name) ?? "—"

        let admissionNumber = nonEmptyText(
            record?.student?.admissionNumber
        ) ?? "—"

        Classsectionandadmissionlabel.text =
            "\(grade) · \(section) · Admission no. \(admissionNumber)"
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
