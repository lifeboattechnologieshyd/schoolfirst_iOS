//
//  AbsentdetailsTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

class AbsentdetailsTBLVCLL: UITableViewCell {

    @IBOutlet weak var ClasssectionandrollnumberLabel: UILabel!
    @IBOutlet weak var MarkedTeachernameLabel: UILabel!
    @IBOutlet weak var RemarksLabel: UILabel!
    @IBOutlet weak var Reason: UILabel!
    @IBOutlet weak var AbsentdateLabel: UILabel!
    @IBOutlet weak var Absentdate: UILabel!
    @IBOutlet weak var Attendancestatuslabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Existing XIB styling and layout remain unchanged.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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

        // Class and section for this attendance record.
        let grade = nonEmptyText(record?.grade?.name) ?? "—"
        let section = nonEmptyText(record?.section?.name) ?? "—"

        // The API provides admission number, not roll number.
        let admissionNumber = nonEmptyText(
            record?.student?.admissionNumber
        ) ?? "—"

        ClasssectionandrollnumberLabel.text =
            "\(grade) · \(section) · Admission no. \(admissionNumber)"

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
