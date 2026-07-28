//
//  PTMmeetingdetailsTableViewCell.swift
//  SchoolFirst
//

import UIKit

class PTMmeetingdetailsTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var MeetingstarttimeLbl: UILabel!
    @IBOutlet weak var MeetingdateLbl: UILabel!
    @IBOutlet weak var Studentgrade: UILabel!
    @IBOutlet weak var StudentnameLBl: UILabel!
    @IBOutlet weak var StaffnameLbl: UILabel!
    @IBOutlet weak var StafftypeLbl: UILabel!
    @IBOutlet weak var ProfileImage: UIImageView!

    // MARK: - Callback
    var onConfirmTap: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle             = .none
        ProfileImage.clipsToBounds = true
        ProfileImage.contentMode   = .scaleAspectFill
        setupDefaultUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StudentnameLBl.text      = nil
        Studentgrade.text        = nil
        MeetingdateLbl.text      = nil
        MeetingstarttimeLbl.text = nil
        StaffnameLbl.text        = nil
        StafftypeLbl.text        = nil
        ProfileImage.image       = UIImage(systemName: "person.circle.fill")
        onConfirmTap             = nil
    }

    // MARK: - Configure
    func configure(with meeting: PTMMeeting?, studentName: String?) {
        guard let meeting = meeting else {
            showLoadingState()
            return
        }

        // ── Student Name ──────────────────────────────────────────────────
        // Use the passed studentName — never use meeting.title here
        let resolvedName = studentName?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty == false
            ? studentName!.trimmingCharacters(in: .whitespacesAndNewlines)
            : "Student"

        StudentnameLBl.text     = resolvedName
        StudentnameLBl.isHidden = false
        StudentnameLBl.alpha    = 1.0

        print("✅ StudentnameLBl → \(resolvedName)")

        // ── Grade & Section ───────────────────────────────────────────────
        Studentgrade.text     = "\(meeting.grade.name) - \(meeting.section.name)"
        Studentgrade.isHidden = false
        Studentgrade.alpha    = 1.0

        print("✅ Studentgrade → \(meeting.grade.name) - \(meeting.section.name)")

        // ── Date ──────────────────────────────────────────────────────────
        MeetingdateLbl.text     = meeting.formattedDate
        MeetingdateLbl.isHidden = false

        // ── Time ──────────────────────────────────────────────────────────
        MeetingstarttimeLbl.text     = meeting.formattedTimeRange
        MeetingstarttimeLbl.isHidden = false

        // ── Host Staff ────────────────────────────────────────────────────
        if let hostStaff = meeting.hostStaff {
            StaffnameLbl.text     = hostStaff.name
            StafftypeLbl.text     = hostStaff.staffType
            StaffnameLbl.isHidden = false
            StafftypeLbl.isHidden = false
            loadProfileImage(urlString: hostStaff.profileImage)
            print("✅ Host Staff → \(hostStaff.name) | \(hostStaff.staffType)")

        } else if let firstStaff = meeting.staffs.first {
            StaffnameLbl.text     = firstStaff.name
            StafftypeLbl.text     = firstStaff.staffType
            StaffnameLbl.isHidden = false
            StafftypeLbl.isHidden = false
            loadProfileImage(urlString: firstStaff.profileImage)
            print("✅ First Staff (fallback) → \(firstStaff.name)")

        } else {
            StaffnameLbl.text     = "Not Assigned"
            StafftypeLbl.text     = ""
            StaffnameLbl.isHidden = false
            StafftypeLbl.isHidden = true
            ProfileImage.image    = UIImage(systemName: "person.circle.fill")
            print("⚠️ No staff found for this meeting")
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 PTMmeetingdetailsTableViewCell configure summary:")
        print("   StudentName : \(resolvedName)")
        print("   Grade       : \(meeting.grade.name) - \(meeting.section.name)")
        print("   Date        : \(meeting.formattedDate)")
        print("   Time        : \(meeting.formattedTimeRange)")
        print("   Host Staff  : \(meeting.hostStaff?.name ?? "None")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Loading State
    private func showLoadingState() {
        StudentnameLBl.text      = "--"
        Studentgrade.text        = "--"
        MeetingdateLbl.text      = "Loading..."
        MeetingstarttimeLbl.text = "Loading..."
        StaffnameLbl.text        = "--"
        StafftypeLbl.text        = "--"
        ProfileImage.image       = UIImage(systemName: "person.circle.fill")
    }

    // MARK: - Profile Image Loader
    private func loadProfileImage(urlString: String?) {
        guard let urlString = urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            ProfileImage.image = UIImage(systemName: "person.circle.fill")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self  = self,
                  let data  = data,
                  error    == nil,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.ProfileImage.image = image
            }
        }.resume()
    }

    // MARK: - Default UI Setup
    private func setupDefaultUI() {
        StudentnameLBl.textColor          = .black
        MeetingdateLbl.textColor          = .black
        MeetingstarttimeLbl.textColor     = .black
        StaffnameLbl.textColor            = .black
        StafftypeLbl.textColor            = .darkGray

        StudentnameLBl.numberOfLines      = 1
        Studentgrade.numberOfLines        = 1
        MeetingdateLbl.numberOfLines      = 1
        MeetingstarttimeLbl.numberOfLines = 2
        StaffnameLbl.numberOfLines        = 1
        StafftypeLbl.numberOfLines        = 1

        ProfileImage.image = UIImage(systemName: "person.circle.fill")
    }
}
