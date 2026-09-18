//
//  TRSPRTcantactdriverVCUITableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

// MARK: - Delegate Protocol for Navigation
protocol TRSPRTcantactdriverCellDelegate: AnyObject {
    func didTapMessageButton()
    func didTapLiveTrackButton()
    func didTapVoiceCallButton()
}

// Global Image Cache
private let imageCache = NSCache<NSString, UIImage>()

class TRSPRTcantactdriverVCUITableViewCell: UITableViewCell {

    @IBOutlet weak var Livetrackbutton: UIButton!
    @IBOutlet weak var RoutenameLabel: UILabel!

    @IBOutlet weak var DrivernameLabel: UILabel!
    // MARK: - Outlets
    @IBOutlet weak var Voicecallbutton: UIButton!
    @IBOutlet weak var Driverimg: UIImageView!
   
    @IBOutlet weak var DriverExperienceLabel: UILabel!
    @IBOutlet weak var BusnumberLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var MessageButton: UIButton!

    // MARK: - Delegate
    weak var delegate: TRSPRTcantactdriverCellDelegate?

    private var imageDownloadTask: URLSessionDataTask?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        clearStaticText()

        // ── DEBUG: verify outlet is connected ──
        print("🔍 DrivernameLabel outlet:", DrivernameLabel == nil ? "❌ NIL (reconnect in XIB)" : "✅ connected")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloadTask?.cancel()
        Driverimg.image = nil
        clearStaticText()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Clear static XIB placeholder text
    private func clearStaticText() {
        DrivernameLabel.text       = "--"
        DriverExperienceLabel.text = "--"
        BusnumberLabel.text        = "--"
        StatusLabel.text           = "--"
        RoutenameLabel.text        = "--"
    }

    // MARK: - Setup UI
    private func setupUI() {
        selectionStyle = .none
        
        // Driver Image Circle Styling
        Driverimg.layer.cornerRadius = Driverimg.frame.size.height / 2
        Driverimg.clipsToBounds = true
        Driverimg.contentMode = .scaleAspectFill

        // Live Track button target
        Livetrackbutton?.addTarget(
            self,
            action: #selector(liveTrackButtonTapped),
            for: .touchUpInside
        )

        // Voice Call button target
        Voicecallbutton?.addTarget(
            self,
            action: #selector(voiceCallButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Configure Data with Model
    func configure(with data: StudentBusData?) {

        guard let data = data else {
            clearStaticText()
            DrivernameLabel.text = "N/A"
            DriverExperienceLabel.text = "N/A"
            BusnumberLabel.text = "N/A"
            StatusLabel.text = "N/A"
            RoutenameLabel.text = "N/A"
            Driverimg.image = UIImage(systemName: "person.circle.fill")
            return
        }

        // ✅ 1. DRIVER NAME — EXACT SAME PATTERN AS DASHBOARD CELL
        DrivernameLabel.text =
            data.driver?.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? data.driver?.name
            : "N/A"

        print("👨‍✈️ DrivernameLabel set to → '\(DrivernameLabel.text ?? "nil")'")

        // 2. Driver Experience
        if let exp = data.driver?.experience {
            if exp.truncatingRemainder(dividingBy: 1) == 0 {
                DriverExperienceLabel.text = "\(Int(exp)) Years Exp"
            } else {
                DriverExperienceLabel.text = "\(exp) Years Exp"
            }
        } else {
            DriverExperienceLabel.text = "N/A"
        }

        // 3. Bus Number
        if let busNo = data.bus?.vehicleNumber,
           !busNo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            BusnumberLabel.text = busNo
        } else {
            BusnumberLabel.text = "N/A"
        }

        // 4. Status
        if let status = data.bus?.status,
           !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            StatusLabel.text = status.capitalized
        } else {
            StatusLabel.text = "Active"
        }

        // 5. Route Name (from API)
        if let routeName = data.route?.routeName,
           !routeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            RoutenameLabel.text = routeName
        } else if let routeCode = data.route?.routeCode,
                  !routeCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            RoutenameLabel.text = routeCode
        } else {
            RoutenameLabel.text = "N/A"
        }

        // 6. Driver Profile Image Download & Cache
        let placeholder = UIImage(systemName: "person.crop.circle.fill")
        Driverimg.image = placeholder

        if let imageString = data.driver?.profileImage,
           !imageString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let url = URL(string: imageString) {
            loadImage(from: url, placeholder: placeholder)
        }
    }

    // MARK: - Native Asynchronous Image Downloader with Cache
    private func loadImage(from url: URL, placeholder: UIImage?) {
        let cacheKey = NSString(string: url.absoluteString)

        if let cachedImage = imageCache.object(forKey: cacheKey) {
            self.Driverimg.image = cachedImage
            return
        }

        imageDownloadTask?.cancel()

        imageDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let downloadedImage = UIImage(data: data),
                  error == nil else {
                return
            }

            imageCache.setObject(downloadedImage, forKey: cacheKey)

            DispatchQueue.main.async {
                self.Driverimg.image = downloadedImage
            }
        }
        imageDownloadTask?.resume()
    }

    // MARK: - Button Actions
    @IBAction func MessageButtonTapped(_ sender: UIButton) {
        print("💬 Message button tapped")
        delegate?.didTapMessageButton()
    }

    @objc private func liveTrackButtonTapped() {
        print("📍 Live Track button tapped")
        delegate?.didTapLiveTrackButton()
    }

    @objc private func voiceCallButtonTapped() {
        print("📞 Voice call button tapped")
        delegate?.didTapVoiceCallButton()
    }

    // Optional: if buttons are already connected via IBAction in XIB
    @IBAction func LivetrackbuttonTapped(_ sender: UIButton) {
        print("📍 Live Track button tapped")
        delegate?.didTapLiveTrackButton()
    }

    @IBAction func VoicecallbuttonTapped(_ sender: UIButton) {
        print("📞 Voice call button tapped")
        delegate?.didTapVoiceCallButton()
    }
}
