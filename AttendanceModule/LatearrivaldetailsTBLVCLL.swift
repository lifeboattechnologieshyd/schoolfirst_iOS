//
//  LatearrivaldetailsTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class LatearrivaldetailsTBLVCLL: UITableViewCell {

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

        // Class and section from the selected record.
        let grade = nonEmptyText(record?.grade?.name) ?? "—"
        let section = nonEmptyText(record?.section?.name) ?? "—"

        let admissionNumber = nonEmptyText(
            record?.student?.admissionNumber
        ) ?? "—"

        // The API supplies an admission number, not a roll number.
        Classsectionandrollnumberlabel.text =
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
