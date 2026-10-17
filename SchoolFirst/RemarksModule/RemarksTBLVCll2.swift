//  RemarksTBLVCll2.swift
//  SchoolFirst
//

import UIKit

class RemarksTBLVCll2: UITableViewCell {

    @IBOutlet weak var Viewdetailsbutton: UIButton!
    @IBOutlet weak var RemarkTitleLabel: UILabel!
    @IBOutlet weak var CatogeryLabel: UILabel!
    @IBOutlet weak var TeacherNameLabel: UILabel!
    @IBOutlet weak var RemarkdateLabel: UILabel!
    @IBOutlet weak var RemarkdescriptionLabel: UILabel!

    // Action closure for the View details button
    var onViewDetailsTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Allow description to wrap if the label supports multi-line in the XIB
        RemarkdescriptionLabel?.numberOfLines = 0
        
        // Add target for button tap
        Viewdetailsbutton.addTarget(self, action: #selector(didTapViewDetails), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc private func didTapViewDetails() {
        onViewDetailsTapped?()
    }

    // MARK: - Configure with RemarkItem
    func configure(with remark: RemarkItem) {
        RemarkTitleLabel.text = remark.title
        CatogeryLabel.text = remark.category.name
        TeacherNameLabel.text = remark.teacher.name
        RemarkdateLabel.text = formatDate(remark.date)
        RemarkdescriptionLabel.text = remark.description
    }

    // MARK: - Date Formatting (yyyy-MM-dd -> d MMM yyyy)
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        return outputFormatter.string(from: date)
    }
}
