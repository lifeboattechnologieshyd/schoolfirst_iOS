//
//  TRSPTchatVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/07/26.
//

import UIKit

// Image cache for chat header
private let chatDriverImageCache = NSCache<NSString, UIImage>()

class TRSPTchatVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var DrivernameLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    
    @IBOutlet weak var CalldriverButton: UIButton!
    @IBOutlet weak var DriverimageView: UIImageView!

    // MARK: - Properties Passed from Contact Driver Screen
    var driverName: String?
    var driverStatus: String?
    var driverImageURL: String?     // ✅ NEW: driver profile image URL
    var driverMobile: String?       // ✅ NEW: driver mobile for call

    private var imageDownloadTask: URLSessionDataTask?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupDriverImageView()
        setupCallButton()
        configureHeaderData()
    }

    deinit {
        imageDownloadTask?.cancel()
    }
    
    // MARK: - Back Button Action
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Configure Data to Outlets
    private func configureHeaderData() {
        // Configure Driver Name
        if let name = driverName, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DrivernameLabel.text = name
        } else {
            DrivernameLabel.text = "Driver"
        }

        // Configure Status
        if let status = driverStatus, !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            StatusLabel.text = status.capitalized
        } else {
            StatusLabel.text = "Active"
        }

        // ✅ Configure Driver Image
        configureDriverImage(urlString: driverImageURL)
    }

    // MARK: - Driver Image Setup
    private func setupDriverImageView() {
        DriverimageView?.contentMode = .scaleAspectFill
        DriverimageView?.clipsToBounds = true
        DriverimageView?.layer.cornerRadius = (DriverimageView?.bounds.height ?? 40) / 2
        setDriverImagePlaceholder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let iv = DriverimageView, iv.bounds.height > 0 {
            iv.layer.cornerRadius = iv.bounds.height / 2
        }
    }

    private func setDriverImagePlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        DriverimageView?.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        DriverimageView?.tintColor = .systemGray3
        DriverimageView?.backgroundColor = .systemGray6
        DriverimageView?.contentMode = .scaleAspectFill
    }

    // MARK: - ✅ Load Driver Image from URL passed by Contact VC
    private func configureDriverImage(urlString: String?) {
        setDriverImagePlaceholder()

        guard var raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            print("⚠️ ChatVC — driver image URL is empty")
            return
        }

        // Auto-convert http → https (ATS safety)
        if raw.hasPrefix("http://") {
            raw = raw.replacingOccurrences(of: "http://", with: "https://")
        }

        guard let url = URL(string: raw) else {
            print("❌ ChatVC — invalid driver image URL: \(raw)")
            return
        }

        let cacheKey = NSString(string: url.absoluteString)

        // Cache hit
        if let cached = chatDriverImageCache.object(forKey: cacheKey) {
            DriverimageView?.image = cached.withRenderingMode(.alwaysOriginal)
            DriverimageView?.tintColor = nil
            DriverimageView?.backgroundColor = .clear
            DriverimageView?.contentMode = .scaleAspectFill
            return
        }

        imageDownloadTask?.cancel()

        imageDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ ChatVC — image download failed: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ ChatVC — image decode failed")
                return
            }

            chatDriverImageCache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                self.DriverimageView?.tintColor = nil
                self.DriverimageView?.backgroundColor = .clear
                self.DriverimageView?.image = image.withRenderingMode(.alwaysOriginal)
                self.DriverimageView?.contentMode = .scaleAspectFill
            }
        }
        imageDownloadTask?.resume()
    }

    // MARK: - ✅ Call Driver Button Setup
    private func setupCallButton() {
        CalldriverButton?.addTarget(
            self,
            action: #selector(callDriverButtonTapped),
            for: .touchUpInside
        )
    }

    @objc private func callDriverButtonTapped() {
        callDriver()
    }

    // Optional: if CalldriverButton is connected via IBAction in storyboard/XIB
    @IBAction func CalldriverButtonTapped(_ sender: UIButton) {
        callDriver()
    }

    // MARK: - ✅ Call Driver using mobile passed from Contact VC
    private func callDriver() {
        guard let phone = driverMobile?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !phone.isEmpty else {
            print("❌ ChatVC — driver mobile not available")
            let alert = UIAlertController(
                title: "Driver Contact",
                message: "Driver phone number is not available.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Clean number
        let cleanNumber = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        guard let url = URL(string: "tel://\(cleanNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            print("❌ ChatVC — cannot place call to: \(cleanNumber)")
            return
        }

        print("📞 ChatVC calling driver: \(cleanNumber)")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - UI Setup
    private func setupTopViewShadow() {
        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }
}
