//
//  PTMonlinemeetTableViewCell3.swift
//  SchoolFirst
//

import UIKit

class PTMonlinemeetTableViewCell3: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var MeetinglinkButton: UIButton!

    // MARK: - Private
    private var meetingLink: String?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupDefaultUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        meetingLink = nil
        MeetinglinkButton.setTitle("Join Meeting", for: .normal)
        MeetinglinkButton.isEnabled = false
        MeetinglinkButton.alpha     = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure (Online meetings only)
    func configure(with meeting: PTMMeeting?) {
        guard let meeting = meeting else {
            MeetinglinkButton.setTitle("Link Unavailable", for: .normal)
            MeetinglinkButton.isEnabled = false
            MeetinglinkButton.alpha     = 0.5
            return
        }

        // Extra guard — only shown for ONLINE meetings
        guard meeting.meetingMode.uppercased() == "ONLINE" else {
            MeetinglinkButton.setTitle("Link Unavailable", for: .normal)
            MeetinglinkButton.isEnabled = false
            MeetinglinkButton.alpha     = 0.5
            return
        }

        if let link = meeting.meetingLink, !link.isEmpty {
            self.meetingLink = link
            MeetinglinkButton.setTitle("Join Meeting", for: .normal)
            MeetinglinkButton.isEnabled = true
            MeetinglinkButton.alpha     = 1.0
            print("✅ PTMonlinemeetTableViewCell3 → Link: \(link)")
        } else {
            self.meetingLink = nil
            MeetinglinkButton.setTitle("Link Not Yet Added", for: .normal)
            MeetinglinkButton.isEnabled = false
            MeetinglinkButton.alpha     = 0.5
            print("⚠️ PTMonlinemeetTableViewCell3 → No meeting link")
        }
    }

    // MARK: - Default UI
    private func setupDefaultUI() {
        MeetinglinkButton.isEnabled = false
        MeetinglinkButton.alpha     = 0.5
        MeetinglinkButton.setTitle("Join Meeting", for: .normal)
    }

    // MARK: - Button Action
    @IBAction func MeetingLinkButtonTapped(_ sender: UIButton) {
        guard let link = meetingLink, !link.isEmpty else {
            print("❌ Meeting link is nil or empty")
            return
        }

        let cleanLink = link.hasPrefix("http://") || link.hasPrefix("https://")
            ? link
            : "https://\(link)"

        guard let url = URL(string: cleanLink) else {
            print("❌ Invalid URL: \(cleanLink)")
            return
        }

        print("🔗 Opening: \(url.absoluteString)")

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                print(success ? "✅ Opened successfully" : "❌ Failed to open")
            }
        } else {
            print("❌ Cannot open URL")
        }
    }
}
