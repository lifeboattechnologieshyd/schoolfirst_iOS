//
//  QueryTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class QueryTableViewCell: UITableViewCell {

    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var CreatedtimeLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        StatusLbl.layer.cornerRadius = 4
        StatusLbl.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with ticket: TicketItem) {
        titleLabel.text = ticket.title ?? "No Title"
        descriptionLabel.text = ticket.description ?? "No Description Provided"
        
        let status = ticket.status ?? "OPEN"
        StatusLbl.text = "  \(status)  "
        
        if status.uppercased() == "OPEN" {
            StatusLbl.textColor = .systemGreen
            StatusLbl.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        } else {
            StatusLbl.textColor = .systemGray
            StatusLbl.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
        }
        
        if let rawDate = ticket.createdAt {
            CreatedtimeLbl.text = formatServerDate(rawDate)
        } else {
            CreatedtimeLbl.text = ""
        }
    }
    
    private func formatServerDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy, hh:mm a"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
