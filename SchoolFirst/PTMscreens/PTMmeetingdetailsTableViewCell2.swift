//
//  PTMmeetingdetailsTableViewCell2.swift
//  SchoolFirst
//

import UIKit

class PTMmeetingdetailsTableViewCell2: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var MeetinglocationLbl: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupDefaultUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        MeetinglocationLbl.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure (Offline meetings only)
    func configure(with meeting: PTMMeeting?) {
        guard let meeting = meeting else {
            MeetinglocationLbl.text = "Location not available"
            return
        }

        // Extra guard — this cell only shows for OFFLINE
        guard meeting.meetingMode.uppercased() != "ONLINE" else {
            MeetinglocationLbl.text = ""
            return
        }

        if let location = meeting.location, !location.isEmpty {
            MeetinglocationLbl.text = location
        } else {
            MeetinglocationLbl.text = "School Campus"
        }

        print("✅ PTMmeetingdetailsTableViewCell2 → Location: \(MeetinglocationLbl.text ?? "nil")")
    }

    // MARK: - Default UI
    private func setupDefaultUI() {
        MeetinglocationLbl.textColor     = .black
        MeetinglocationLbl.numberOfLines = 0
        MeetinglocationLbl.lineBreakMode = .byWordWrapping
    }
}
