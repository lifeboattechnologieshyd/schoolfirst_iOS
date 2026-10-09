//
//  HomeworkStudentTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkStudentTableViewCell1: UITableViewCell {

    @IBOutlet weak var StudentgradeandSectionLbl: UILabel!
    @IBOutlet weak var StudentNameLbl: UILabel!
    @IBOutlet weak var Backgroungview: UIView!

    @IBOutlet weak var Studentimageview: UIImageView!

    // MARK: - Profile Image Cache (shared across cell instances)
    private static let profileImageCache = NSCache<NSString, UIImage>()

    // Tracks which student's photo this cell is currently showing/loading
    private var currentPhotoURLString: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        StudentNameLbl.text = UserManager.shared.resolvedStudentName
        StudentgradeandSectionLbl.text   = UserManager.shared.resolvedGradeSection

        // ── Profile Image Setup + Load ──────────────────────────────
        setupProfileImageView()
        loadStudentProfileImage()

        // Light Gray Shadow
        Backgroungview.layer.shadowColor = UIColor.lightGray.cgColor
        Backgroungview.layer.shadowOpacity = 0.4
        Backgroungview.layer.shadowOffset = CGSize(width: 0, height: 2)
        Backgroungview.layer.shadowRadius = 4
        Backgroungview.layer.masksToBounds = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Prevent flashing the previous student's photo on reuse
        currentPhotoURLString = nil
        Studentimageview.image = profilePlaceholderImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        Backgroungview.layer.shadowPath = UIBezierPath(rect: Backgroungview.bounds).cgPath

        // Keep profile image perfectly circular
        Studentimageview.layer.cornerRadius = min(Studentimageview.bounds.width,
                                                  Studentimageview.bounds.height) / 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Public Refresh (called from cellForRowAt)
    /// awakeFromNib runs only once — this ensures the correct photo
    /// is shown when the selected student changes on a reused cell.
    func refreshProfileImage() {
        loadStudentProfileImage()
    }

    // MARK: - Profile Image Setup
    private func setupProfileImageView() {
        Studentimageview.contentMode        = .scaleAspectFill
        Studentimageview.clipsToBounds      = true
        Studentimageview.layer.masksToBounds = true
        Studentimageview.tintColor          = .lightGray
        Studentimageview.image              = profilePlaceholderImage()
    }

    // MARK: - Load Profile Image from UserManager
    private func loadStudentProfileImage() {

        let urlString = UserManager.shared.resolvedStudentPhotoURL
        currentPhotoURLString = urlString

        print("🖼️ HomeworkStudentCell — photo URL:", urlString.isEmpty ? "empty" : urlString)

        // No photo saved for this student → show placeholder
        guard !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Studentimageview.image = profilePlaceholderImage()
            return
        }

        // Build URL (tolerates unencoded characters in URL string)
        guard let url = URL(string: urlString)
                ?? URL(string: urlString.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("❌ HomeworkStudentCell — invalid photo URL:", urlString)
            Studentimageview.image = profilePlaceholderImage()
            return
        }

        // 1) Memory cache hit → set instantly, no network call
        if let cachedImage = Self.profileImageCache.object(forKey: urlString as NSString) {
            Studentimageview.image = cachedImage
            return
        }

        // 2) Download asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }

            guard error == nil,
                  let data = data,
                  let downloadedImage = UIImage(data: data) else {
                print("❌ HomeworkStudentCell — photo download failed:",
                      error?.localizedDescription ?? "invalid image data")
                DispatchQueue.main.async {
                    if self.currentPhotoURLString == urlString {
                        self.Studentimageview.image = self.profilePlaceholderImage()
                    }
                }
                return
            }

            // Cache for future reuse
            Self.profileImageCache.setObject(downloadedImage, forKey: urlString as NSString)

            DispatchQueue.main.async {
                // Cell may have been reused for a different student — verify first
                guard self.currentPhotoURLString == urlString else { return }
                self.Studentimageview.image = downloadedImage
                print("✅ HomeworkStudentCell — profile image loaded")
            }
        }.resume()
    }

    // MARK: - Placeholder
    private func profilePlaceholderImage() -> UIImage? {
        return UIImage(systemName: "person.circle.fill")
    }
}
