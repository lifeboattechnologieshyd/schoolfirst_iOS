//
//  RemarksdetailsTBLVCll1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/10/26.
//

import UIKit

class RemarksdetailsTBLVCll1: UITableViewCell {

    @IBOutlet weak var TeachernamefirsttwolettersLabel: UILabel!
    @IBOutlet weak var CatogeryLabel1: UILabel!
    @IBOutlet weak var RemarkIDLabel: UILabel!
    @IBOutlet weak var RemarktitleLabel: UILabel!
    @IBOutlet weak var CatogeryLabel: UILabel!
   
    @IBOutlet weak var StudentnameandgradeLabel: UILabel!
    @IBOutlet weak var Cantainerview: UIView!
    @IBOutlet weak var RemarkdescriptionLabel: UILabel!
    @IBOutlet weak var RemarkdateandtimeLabel: UILabel!
    @IBOutlet weak var RemarkContextLabel: UILabel!
    @IBOutlet weak var SubejectLabel: UILabel!
    @IBOutlet weak var RemarkSubjectLabel: UILabel!
    @IBOutlet weak var TeachernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - API Mapping Logic
    func configure(with remark: RemarkItem) {
        RemarktitleLabel.text = remark.title
        CatogeryLabel.text = remark.category.name
        CatogeryLabel1.text = remark.category.name
        
        TeachernameLabel.text = remark.teacher.name
        RemarkdescriptionLabel.text = remark.description
        
        RemarkContextLabel.text = remark.context
        RemarkSubjectLabel.text = remark.subject.name
        
        RemarkIDLabel.text = getInitials(from: remark.teacher.name)
        
        // Teacher name first two characters
        TeachernamefirsttwolettersLabel.text = getInitials(from: remark.teacher.name)
        
        StudentnameandgradeLabel.text = "\(remark.student.name) • \(remark.grade.name) \(remark.section.name)"
        
        RemarkdateandtimeLabel.text = formatDateTime(remark.created_at)
    }
    
    // MARK: - Helpers
    private func getInitials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            if let first = parts[0].first, let second = parts[1].first {
                return "\(first)\(second)".uppercased()
            }
        } else if let first = name.first {
            return "\(first)".uppercased()
        }
        return ""
    }
    
    private func formatDateTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = formatter.date(from: isoString)
        
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }
        
        guard let validDate = date else { return isoString }
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "d MMM yyyy • h:mm a"
        outFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return outFormatter.string(from: validDate)
    }
}
