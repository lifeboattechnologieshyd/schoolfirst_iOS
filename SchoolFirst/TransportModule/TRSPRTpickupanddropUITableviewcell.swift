//
//  TRSPRTpickupanddropUITableviewcell.swift
//  SchoolFirst
//

import UIKit

// Image cache for this header cell
private let pickupHeaderImageCache = NSCache<NSString, UIImage>()

class TRSPRTpickupanddropUITableviewcell: UITableViewCell {

    @IBOutlet weak var StudentProfileimageview: UIImageView!
    @IBOutlet weak var RoutecodeLabel: UILabel!
    @IBOutlet weak var StudentgradeLabel: UILabel!
    @IBOutlet weak var BusnumberLabel: UILabel!
    @IBOutlet weak var StudentNameLbl: UILabel!
    @IBOutlet weak var segmentcontroller: UISegmentedControl!

    // Closure to notify the view controller when segment changes
    var onSegmentChange: ((Int) -> Void)?

    private var studentImageTask: URLSessionDataTask?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupFonts()
        StudentNameLbl.text = UserManager.shared.resolvedStudentName
        setupSegmentAppearance()
        setupStudentImageView()

        // ✅ Auto-load student photo saved from login / profile screen
        configureStudentImage(urlString: UserManager.shared.resolvedStudentPhotoURL)

        // ✅ Auto-configure grade from UserDefaults (saved at login)
        configureGrade()

        segmentcontroller.addTarget(
            self,
            action: #selector(segmentValueChanged(_:)),
            for: .valueChanged
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        studentImageTask?.cancel()
        studentImageTask = nil
        setStudentImagePlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let iv = StudentProfileimageview, iv.bounds.height > 0 {
            iv.layer.cornerRadius = iv.bounds.height / 2
        }
    }
    
    private func setupFonts() {
        StudentNameLbl?.font = .hankenSemiBold(size: 20)
        RoutecodeLabel?.font = .hankenSemiBold(size: 20)
        BusnumberLabel?.font = .hankenRegular(size: 16)
    }

    // MARK: - Segment Appearance
    private func setupSegmentAppearance() {
        // Normal (unselected) state → Black text
        segmentcontroller.setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Selected state → White text
        segmentcontroller.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
    }

    // MARK: - Student Image Setup
    private func setupStudentImageView() {
        StudentProfileimageview?.contentMode = .scaleAspectFill
        StudentProfileimageview?.clipsToBounds = true
        StudentProfileimageview?.layer.cornerRadius = (StudentProfileimageview?.bounds.height ?? 50) / 2
        setStudentImagePlaceholder()
    }

    private func setStudentImagePlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        StudentProfileimageview?.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        StudentProfileimageview?.tintColor = UIColor.white.withAlphaComponent(0.85)
        StudentProfileimageview?.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        StudentProfileimageview?.contentMode = .scaleAspectFill
    }

    // MARK: - ✅ Configure Student Profile Image (from saved photo URL)
    func configureStudentImage(urlString: String?) {
        setStudentImagePlaceholder()

        guard var raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            print("⚠️ Student photo URL is empty in pickup header cell")
            return
        }

        // Auto-convert http → https (ATS safety)
        if raw.hasPrefix("http://") {
            raw = raw.replacingOccurrences(of: "http://", with: "https://")
        }

        guard let url = URL(string: raw) else {
            print("❌ Invalid student photo URL: \(raw)")
            return
        }

        let cacheKey = NSString(string: url.absoluteString)

        // Cache hit
        if let cached = pickupHeaderImageCache.object(forKey: cacheKey) {
            StudentProfileimageview?.image = cached.withRenderingMode(.alwaysOriginal)
            StudentProfileimageview?.tintColor = nil
            StudentProfileimageview?.backgroundColor = .clear
            StudentProfileimageview?.contentMode = .scaleAspectFill
            return
        }

        studentImageTask?.cancel()

        studentImageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ Student image download failed: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Student image decode failed from \(url)")
                return
            }

            pickupHeaderImageCache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                self.StudentProfileimageview?.tintColor = nil
                self.StudentProfileimageview?.backgroundColor = .clear
                self.StudentProfileimageview?.image = image.withRenderingMode(.alwaysOriginal)
                self.StudentProfileimageview?.contentMode = .scaleAspectFill
            }
        }
        studentImageTask?.resume()
    }

    // MARK: - Configuration Methods
    func configureStudentName(_ name: String?) {
        if let studentName = name, !studentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            StudentNameLbl.text = studentName
        } else {
            StudentNameLbl.text = UserManager.shared.resolvedStudentName
        }
    }

    // MARK: - ✅ Configure Grade from UserDefaults
    /// Reads "Grade 5 - A" resolved from STUDENT_GRADE_SECTION (saved at login / kid switch).
    /// Pass a custom value to override, or call with no argument to auto-resolve.
    func configureGrade(_ gradeText: String? = nil) {
        let resolved: String
        if let gradeText = gradeText,
           !gradeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            resolved = gradeText
        } else {
            // UserManager → in-memory selectedKid, fallback UserDefaults["STUDENT_GRADE_SECTION"]
            resolved = UserManager.shared.resolvedGradeSection
        }

        if !resolved.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            StudentgradeLabel.text = resolved
        } else {
            StudentgradeLabel.text = "N/A"
        }
    }

    func configureBusNumber(_ busNumber: String?) {
        if let busNo = busNumber, !busNo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            BusnumberLabel.text = busNo
        } else {
            BusnumberLabel.text = "N/A"
        }
    }

    func configureRouteCode(_ routeCode: String?) {
        if let code = routeCode, !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            RoutecodeLabel.text = code
        } else {
            RoutecodeLabel.text = "N/A"
        }
    }

    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        onSegmentChange?(sender.selectedSegmentIndex)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
