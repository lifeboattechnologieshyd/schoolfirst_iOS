//
//  PTMmeetingdetailsTableViewCell.swift
//  SchoolFirst
//

import UIKit

class PTMmeetingdetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var MeetinglocationLbl: UILabel!
    
    @IBOutlet weak var MeetingstarttimeLbl: UILabel!
    @IBOutlet weak var MeetingdateLbl: UILabel!
    @IBOutlet weak var Studentgrade: UILabel!
    @IBOutlet weak var StudentnameLBl: UILabel!
    @IBOutlet weak var StaffnameLbl: UILabel!
    @IBOutlet weak var StafftypeLbl: UILabel!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var ConfirmButton: UIButton!

    var onConfirmTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        ConfirmButton.addTarget(
            self,
            action: #selector(confirmButtonTapped),
            for: .touchUpInside
        )

        ProfileImage.clipsToBounds = true
        ProfileImage.contentMode = .scaleAspectFill

        setupDefaultUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        StudentnameLBl.text = nil
        Studentgrade.text = nil
        DescriptionLbl.text = nil
        MeetingdateLbl.text = nil
        MeetingstarttimeLbl.text = nil
        MeetinglocationLbl.text = nil
        StaffnameLbl.text = nil
        StafftypeLbl.text = nil

        StudentnameLBl.isHidden = false
        Studentgrade.isHidden = false
        DescriptionLbl.isHidden = false
        MeetingdateLbl.isHidden = false
        MeetingstarttimeLbl.isHidden = false
        MeetinglocationLbl.isHidden = false
        StaffnameLbl.isHidden = false
        StafftypeLbl.isHidden = false
        ConfirmButton.isHidden = false

        StudentnameLBl.alpha = 1.0
        Studentgrade.alpha = 1.0
        DescriptionLbl.alpha = 1.0
        MeetingdateLbl.alpha = 1.0
        MeetingstarttimeLbl.alpha = 1.0
        MeetinglocationLbl.alpha = 1.0
        StaffnameLbl.alpha = 1.0
        StafftypeLbl.alpha = 1.0
        ConfirmButton.alpha = 1.0

        ProfileImage.image = UIImage(systemName: "person.circle.fill")

        onConfirmTap = nil
    }

    private func setupDefaultUI() {
        StudentnameLBl.textColor = .black
        DescriptionLbl.textColor = .black
        MeetingdateLbl.textColor = .black
        MeetingstarttimeLbl.textColor = .black
        MeetinglocationLbl.textColor = .black
        StaffnameLbl.textColor = .black
        StafftypeLbl.textColor = .darkGray

        StudentnameLBl.numberOfLines = 1
        Studentgrade.numberOfLines = 1
        DescriptionLbl.numberOfLines = 0
        MeetingdateLbl.numberOfLines = 1
        MeetingstarttimeLbl.numberOfLines = 2
        MeetinglocationLbl.numberOfLines = 2
        StaffnameLbl.numberOfLines = 1
        StafftypeLbl.numberOfLines = 1

        StudentnameLBl.isHidden = false
        Studentgrade.isHidden = false
        DescriptionLbl.isHidden = false
        MeetingdateLbl.isHidden = false
        MeetingstarttimeLbl.isHidden = false
        MeetinglocationLbl.isHidden = false
        StaffnameLbl.isHidden = false
        StafftypeLbl.isHidden = false
        ConfirmButton.isHidden = false

        StudentnameLBl.alpha = 1.0
        Studentgrade.alpha = 1.0
        DescriptionLbl.alpha = 1.0
        MeetingdateLbl.alpha = 1.0
        MeetingstarttimeLbl.alpha = 1.0
        MeetingstarttimeLbl.alpha = 1.0
        MeetinglocationLbl.alpha = 1.0
        StaffnameLbl.alpha = 1.0
        StafftypeLbl.alpha = 1.0
        ConfirmButton.alpha = 1.0
    }

    func configure(meeting: PTMMeeting, student: PTMStudent) {

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 PTMmeetingdetailsTableViewCell configure()")
        print("   student name :", student.name)
        print("   grade        :", meeting.grade.name)
        print("   section      :", meeting.section.name)
        print("   description  :", meeting.description)
        print("   date         :", meeting.formattedDate)
        print("   time         :", meeting.formattedTimeRange)
        print("   location     :", meeting.location ?? "nil")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        setupDefaultUI()

        // Student
        StudentnameLBl.text = student.name.isEmpty ? "Student" : student.name
        Studentgrade.text = "\(meeting.grade.name) - \(meeting.section.name)"

        // Meeting
        DescriptionLbl.text = meeting.description.isEmpty ? "No description available" : meeting.description
        MeetingdateLbl.text = meeting.formattedDate
        MeetingstarttimeLbl.text = meeting.formattedTimeRange

        if meeting.meetingMode.uppercased() == "OFFLINE" {
            MeetinglocationLbl.text = (meeting.location?.isEmpty == false) ? meeting.location : "School"
        } else {
            MeetinglocationLbl.text = (meeting.meetingLink?.isEmpty == false) ? meeting.meetingLink : "Online"
        }

        // Staff
        let preferredStaff = meeting.hostStaff ?? meeting.staffs.first

        if let staff = preferredStaff {
            StaffnameLbl.text = staff.name
            StafftypeLbl.text = staff.staffType

            if let imageString = staff.profileImage,
               let imageURL = URL(string: imageString) {
                loadImage(from: imageURL)
            } else {
                ProfileImage.image = UIImage(systemName: "person.circle.fill")
            }
        } else {
            StaffnameLbl.text = "No Staff Assigned"
            StafftypeLbl.text = "N/A"
            ProfileImage.image = UIImage(systemName: "person.circle.fill")
        }

        setupConfirmButton(using: meeting.response)
    }

    private func setupConfirmButton(using response: PTMMeetingResponse?) {

        // Only update title & enabled state — keep storyboard styling (color, font, corner radius)
        ConfirmButton.isHidden = false
        ConfirmButton.alpha = 1.0

        guard let response = response else {
            ConfirmButton.setTitle("Confirm Attendance", for: .normal)
            ConfirmButton.isEnabled = true
            return
        }

        switch response.responseStatus.uppercased() {
        case "ATTENDING":
            ConfirmButton.setTitle("Attending", for: .normal)
            ConfirmButton.isEnabled = false

        case "NOT_ATTENDING":
            ConfirmButton.setTitle("Not Attending", for: .normal)
            ConfirmButton.isEnabled = false

        case "MAYBE":
            ConfirmButton.setTitle("Maybe", for: .normal)
            ConfirmButton.isEnabled = false

        case "PENDING":
            ConfirmButton.setTitle("Confirm Attendance", for: .normal)
            ConfirmButton.isEnabled = true

        default:
            ConfirmButton.setTitle("Confirm Attendance", for: .normal)
            ConfirmButton.isEnabled = true
        }
    }

    private func loadImage(from url: URL) {
        ProfileImage.image = UIImage(systemName: "person.circle.fill")

        let cacheKey = url.absoluteString as NSString
        if let cachedImage = PTMImageCache.shared.object(forKey: cacheKey) {
            ProfileImage.image = cachedImage
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }

            PTMImageCache.shared.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                self?.ProfileImage.image = image
            }
        }.resume()
    }

    @objc private func confirmButtonTapped() {
        onConfirmTap?()
    }
}

final class PTMImageCache {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}
