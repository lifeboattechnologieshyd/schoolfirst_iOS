//
//  QueryTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class QueryTableViewCell: UITableViewCell {

    @IBOutlet weak var TicketidLbl: UILabel!
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
        
        // Explicitly set text behavior to prevent overlapping layouts in a 150px cell
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        
        descriptionLabel.numberOfLines = 3 // Allows descriptions to wrap gracefully up to 3 lines
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.textColor = .darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with ticket: TicketItem) {
        // Configure Ticket ID Label
        if let id = ticket.id, !id.isEmpty {
            TicketidLbl.text = id.hasPrefix("#") ? id : "#\(id)"
        } else {
            TicketidLbl.text = ""
        }
        
        // Configure Title Label
        titleLabel.text = (ticket.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? ticket.title
            : "No Title"
        
        // Configure Description Label
        let cleanDescription = ticket.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let desc = cleanDescription, !desc.isEmpty {
            descriptionLabel.text = desc
        } else {
            descriptionLabel.text = "No Description Provided"
        }
        
        // Configure Status Badge Label
        let status = (ticket.status ?? "OPEN").uppercased()
        StatusLbl.text = "  \(status)  "
        
        if status == "OPEN" {
            StatusLbl.textColor = .systemGreen
            StatusLbl.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        } else if status == "IN PROGRESS" || status == "PENDING" {
            StatusLbl.textColor = .systemOrange
            StatusLbl.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
        } else {
            StatusLbl.textColor = .systemGray
            StatusLbl.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
        }
        
        // Configure Date Label
        if let rawDate = ticket.createdAt, !rawDate.isEmpty {
            CreatedtimeLbl.text = formatServerDate(rawDate)
        } else {
            CreatedtimeLbl.text = ""
        }
    }
    
    private func formatServerDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return displayFormattedDate(date)
        }
        
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return displayFormattedDate(date)
        }
        
        let customFormatter = DateFormatter()
        customFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            customFormatter.dateFormat = format
            if let date = customFormatter.date(from: dateString) {
                return displayFormattedDate(date)
            }
        }
        
        return dateString
    }
    
    private func displayFormattedDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM yyyy, hh:mm a"
        return displayFormatter.string(from: date)
    }
}
