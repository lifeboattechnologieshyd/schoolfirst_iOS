//
//  PTMhomeTableViewCell1.swift
//  SchoolFirst
//

import UIKit

class PTMhomeTableViewCell1: UITableViewCell {

    @IBOutlet weak var Totalattendedview: UIView!
    @IBOutlet weak var UpcomingmeetingDateLbl: UILabel!
    // MARK: - Outlets
    @IBOutlet weak var UpcomingmeetingsLbl: UILabel!
    @IBOutlet weak var TotalmeetingattendedcountLbl: UILabel!
    @IBOutlet weak var ViewcalendarButton: UIButton!
    @IBOutlet weak var StudentnameLBl: UILabel!
    @IBOutlet weak var CardsBackgroungView: UIView!
    @IBOutlet weak var upcomingCountLabel: UILabel!

    @IBOutlet weak var Studentprofileimage: UIImageView!

    // MARK: - Profile Image Cache & Tracking
    private static let profileImageCache = NSCache<NSString, UIImage>()
    private var currentPhotoURL: String?

    // MARK: - Callbacks
    var onDetailsTapped: (() -> Void)?
    var onCalendarTapped: (() -> Void)?
    var onAttendedHistoryTapped: (() -> Void)?   // ✅ Totalattendedview tap

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        ViewcalendarButton.addTarget(
            self,
            action: #selector(didTapCalendar),
            for: .touchUpInside
        )

        // ── Tap gesture on Totalattendedview ─────────────────────
        let attendedTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapAttendedView)
        )
        Totalattendedview.isUserInteractionEnabled = true
        Totalattendedview.addGestureRecognizer(attendedTap)

        // ── Student Profile Image Setup ──────────────────────────
        setupStudentProfileImage()
        loadStudentProfileImage()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StudentnameLBl.text                = nil
        upcomingCountLabel.text            = nil
        TotalmeetingattendedcountLbl.text  = nil
        UpcomingmeetingDateLbl.text        = nil
        UpcomingmeetingsLbl.text           = nil // Added for cleanup
        onDetailsTapped                    = nil
        onCalendarTapped                   = nil
        onAttendedHistoryTapped            = nil

        // ✅ Reload image on reuse so a student switch shows correct photo
        Studentprofileimage.image = placeholderImage()
        loadStudentProfileImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // ✅ Make profile image perfectly circular
        Studentprofileimage.layer.cornerRadius = Studentprofileimage.frame.width / 2
        Studentprofileimage.layer.masksToBounds = true
    }

    // MARK: - Student Profile Image Setup
    private func setupStudentProfileImage() {
        Studentprofileimage.contentMode = .scaleAspectFill
        Studentprofileimage.clipsToBounds = true
        Studentprofileimage.image = placeholderImage()
    }

    private func placeholderImage() -> UIImage? {
        return UIImage(systemName: "person.crop.circle.fill")
    }

    // MARK: - Load Student Profile Image from UserManager
    private func loadStudentProfileImage() {
        let urlString = UserManager.shared.resolvedStudentPhotoURL
        currentPhotoURL = urlString

        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            print("⚠️ PTMhomeCell1: No photo URL — showing placeholder")
            Studentprofileimage.image = placeholderImage()
            return
        }

        // ✅ Use cached image if available
        if let cached = Self.profileImageCache.object(forKey: urlString as NSString) {
            Studentprofileimage.image = cached
            return
        }

        // Show placeholder while downloading
        Studentprofileimage.image = placeholderImage()

        // ✅ Download asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                print("❌ PTMhomeCell1: Profile image download failed")
                return
            }

            Self.profileImageCache.setObject(image, forKey: urlString as NSString)

            DispatchQueue.main.async {
                // Ensure cell wasn't reused for a different student
                guard self.currentPhotoURL == urlString else { return }
                self.Studentprofileimage.image = image
                print("✅ PTMhomeCell1: Profile image loaded")
            }
        }.resume()
    }

    // MARK: - Actions
    @objc func didTapDetails() {
        onDetailsTapped?()
    }

    @objc func didTapCalendar() {
        onCalendarTapped?()
    }

    // Totalattendedview tapped
    @objc func didTapAttendedView() {
        print("👆 Totalattendedview tapped")
        onAttendedHistoryTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
