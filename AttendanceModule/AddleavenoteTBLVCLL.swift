//
//  AddleavenoteTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

protocol AddleavenoteTBLVCLLDelegate: AnyObject {
    func didTapSubmitLeaveNote(note: String)
}

class AddleavenoteTBLVCLL: UITableViewCell {

    @IBOutlet weak var SubmitnoteButton: UIButton!
    @IBOutlet weak var Documrntaploadbutton: UIButton!
    @IBOutlet weak var Addnotetextfield: UITextField!
    
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var Cantainerview: UIView!
    @IBOutlet weak var attendancetypeLabel: UILabel!
    @IBOutlet weak var RequestdateLabel: UILabel!
    @IBOutlet weak var Colorverticalview: UIView!
    
    weak var delegate: AddleavenoteTBLVCLLDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        SubmitnoteButton.addTarget(self, action: #selector(didTapSubmitNoteButton), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func didTapSubmitNoteButton() {
        delegate?.didTapSubmitLeaveNote(note: Addnotetextfield.text ?? "")
    }
    
    // MARK: - Configure
    func configure(attendanceStatus: String?, attendanceDate: String?) {
        
        // Attendance Type
        let status = nonEmptyText(attendanceStatus)
        attendancetypeLabel.text = status?
            .replacingOccurrences(of: "_", with: " ")
            .capitalized ?? "—"
        
        // Request Date
        RequestdateLabel.text = formattedDate(
            attendanceDate,
            format: "dd MMM yyyy"
        )
        
        Addnotetextfield.text = ""
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
