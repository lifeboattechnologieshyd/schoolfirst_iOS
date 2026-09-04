//
//  PTMpurposemeetTableViewCell4.swift
//  SchoolFirst
//

import UIKit

class PTMpurposemeetTableViewCell4: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var DeclineButton: UIButton!
    @IBOutlet weak var ConfirmButton: UIButton!
    @IBOutlet weak var DescriptionLbl: UILabel!

    // MARK: - Callbacks
    var onConfirmTap: (() -> Void)?
    var onDeclineTap: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupDefaultUI()
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        DescriptionLbl.text = nil
        onConfirmTap        = nil
        onDeclineTap        = nil
        resetButtonStates()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure
    func configure(with meeting: PTMMeeting?) {
        guard let meeting = meeting else {
            DescriptionLbl.text = "Loading meeting details..."
            resetButtonStates()
            return
        }

        // ── Description / Purpose ─────────────────────────────────────────
        if meeting.description.isEmpty {
            DescriptionLbl.text = "No description provided for this meeting."
        } else {
            DescriptionLbl.text = meeting.description
        }

        // ── Response Status Handling ──────────────────────────────────────
        if let response = meeting.response {
            handleExistingResponse(response)
        } else {
            // No response yet — show both buttons active
            setConfirmButtonState(enabled: true,  title: "Confirm")
            setDeclineButtonState(enabled: true,  title: "Decline")
        }

        print("✅ PTMpurposemeetTableViewCell4 configured:")
        print("   Description    : \(meeting.description)")
        print("   Response Status: \(meeting.response?.responseStatus ?? "None")")
    }

    // MARK: - Existing Response State
    private func handleExistingResponse(_ response: PTMMeetingResponse) {
        switch response.responseStatus {
        case "ATTENDING":
            // Already confirmed
            setConfirmButtonState(enabled: false, title: "✓ Confirmed")
            setDeclineButtonState(enabled: true,  title: "Decline")
            ConfirmButton.backgroundColor = .green
            ConfirmButton.setTitleColor(.white, for: .normal)

        case "NOT_ATTENDING":
            // Already declined
            setConfirmButtonState(enabled: true,  title: "Confirm")
            setDeclineButtonState(enabled: false, title: "✗ Declined")
            DeclineButton.backgroundColor = .red
            DeclineButton.setTitleColor(.white, for: .normal)

        case "MAYBE":
            // Pending — show both enabled
            setConfirmButtonState(enabled: true,  title: "Confirm")
            setDeclineButtonState(enabled: true,  title: "Decline")

        default:
            setConfirmButtonState(enabled: true,  title: "Confirm")
            setDeclineButtonState(enabled: true,  title: "Decline")
        }
    }

    // MARK: - Button State Helpers
    private func setConfirmButtonState(enabled: Bool, title: String) {
        ConfirmButton.isEnabled = enabled
        ConfirmButton.setTitle(title, for: .normal)
        ConfirmButton.alpha = enabled ? 1.0 : 0.7
    }

    private func setDeclineButtonState(enabled: Bool, title: String) {
        DeclineButton.isEnabled = enabled
        DeclineButton.setTitle(title, for: .normal)
        DeclineButton.alpha = enabled ? 1.0 : 0.7
    }

    private func resetButtonStates() {
        setConfirmButtonState(enabled: true, title: "Confirm")
        setDeclineButtonState(enabled: true, title: "Decline")
        ConfirmButton.backgroundColor = nil
        DeclineButton.backgroundColor = nil
    }

    // MARK: - Default UI
    private func setupDefaultUI() {
        DescriptionLbl.textColor    = .darkGray
        DescriptionLbl.numberOfLines = 0
        DescriptionLbl.lineBreakMode = .byWordWrapping

        ConfirmButton.layer.cornerRadius = 8
        DeclineButton.layer.cornerRadius = 8
        ConfirmButton.clipsToBounds      = true
        DeclineButton.clipsToBounds      = true
    }

    // MARK: - Button Actions
    @IBAction func ConfirmButtonTapped(_ sender: UIButton) {
        print("✅ Confirm button tapped in PTMpurposemeetTableViewCell4")
        onConfirmTap?()
    }

    @IBAction func DeclineButtonTapped(_ sender: UIButton) {
        print("❌ Decline button tapped in PTMpurposemeetTableViewCell4")
        onDeclineTap?()
    }
}
