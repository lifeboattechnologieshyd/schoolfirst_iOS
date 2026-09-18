//
//  TRNSPTdashbordUITableViewCell1.swift
//  SchoolFirst
//

import UIKit

// MARK: - Delegate Protocol for Navigation
protocol TRNSPTdashbordCell1Delegate: AnyObject {
    func didTapLiveTracking()
    func didTapDriverContact()
    func didTapFeeModule()
    func didTapPickupandDrop()
    func didTapCallDriver()
}

// Shared image cache for dashboard cell
private let dashImageCache = NSCache<NSString, UIImage>()

class TRNSPTdashbordUITableViewCell1: UITableViewCell {

    @IBOutlet weak var DriverImageview: UIImageView!
    @IBOutlet weak var DroplocationView: UIView!
    @IBOutlet weak var DropTime: UILabel!
    
    @IBOutlet weak var PickupTime: UILabel!
    @IBOutlet weak var OnrouteView: UIView!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var PickuplocationView: UIView!
    @IBOutlet weak var DroplocationLabel: UILabel!
    @IBOutlet weak var PickuplocationLabel: UILabel!
    @IBOutlet weak var PickuptimeLabel: UILabel!
    
    @IBOutlet weak var Studentprofileimageview: UIImageView!
    // MARK: - Outlets
    @IBOutlet weak var CalldriverButton: UIButton!
    @IBOutlet weak var Busimageview: UIImageView!
    @IBOutlet weak var DrivernameLabel: UILabel!
    @IBOutlet weak var BusnumberLabel: UILabel!
    @IBOutlet weak var StudentgradeLbl: UILabel!
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var CollectionView2: UICollectionView!   // Today's Journey list
    @IBOutlet weak var CollectionView: UICollectionView!    // Top module cards

    // MARK: - Delegate
    weak var delegate: TRNSPTdashbordCell1Delegate?

    private var driverImageTask: URLSessionDataTask?
    private var busImageTask: URLSessionDataTask?
    private var studentImageTask: URLSessionDataTask?

    // MARK: - Layout Constants (Top cards)
    private let cardSpacing: CGFloat   = 2
    private let sideInset: CGFloat     = 14
    private let cardHeight: CGFloat    = 126

    // MARK: - Transport Item Model (Top cards)
    private struct TransportItem {
        let title: String
        let description: String
        let imageName: String
        let backgroundColor: UIColor
        let iconTintColor: UIColor
    }

    private let items: [TransportItem] = [
        TransportItem(
            title: "Live\nTracking",
            description: "Track bus live",
            imageName: "icon 42",
            backgroundColor: UIColor(red: 210/255, green: 232/255, blue: 220/255, alpha: 1.0),
            iconTintColor:   UIColor(red:  46/255, green: 139/255, blue:  87/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Driver\nContact",
            description: "Call or message",
            imageName: "icon 43",
            backgroundColor: UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 230/255, green: 120/255, blue:  40/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Fee\nModule",
            description: "Manage Payments",
            imageName: "icon44",
            backgroundColor: UIColor(red: 225/255, green: 220/255, blue: 245/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 170/255, green: 110/255, blue: 200/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Pickup&Drop\nDetails",
            description: "View timings",
            imageName: "icon 45",
            backgroundColor: UIColor(red: 232/255, green: 225/255, blue: 245/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 220/255, green:  80/255, blue: 150/255, alpha: 1.0)
        )
    ]

    // MARK: - Today's Journey Model
    private struct JourneyItem {
        let title: String
        let time: String
        let location: String
        let imageName: String
        let iconTintColor: UIColor
        let iconBackgroundColor: UIColor
    }

    private var journeyItems: [JourneyItem] = []

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        StudentnameLbl.text  = UserManager.shared.resolvedStudentName
        StudentgradeLbl.text = UserManager.shared.resolvedGradeSection
        
        selectionStyle = .none
        setupImageViews()
        setupCallButton()

        print("🔍 CollectionView  :", CollectionView  == nil ? "❌ NIL" : "✅ connected")
        print("🔍 CollectionView2 :", CollectionView2 == nil ? "❌ NIL" : "✅ connected")

        setupTopCollectionView()
        setupJourneyCollectionView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        driverImageTask?.cancel()
        busImageTask?.cancel()
        studentImageTask?.cancel()
        driverImageTask = nil
        busImageTask = nil
        studentImageTask = nil

        setDriverPlaceholder()
        setBusPlaceholder()
        setStudentPlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Driver — circular
        if let iv = DriverImageview, iv.bounds.height > 0 {
            iv.layer.cornerRadius = iv.bounds.height / 2
        }
        
        // Bus — square with corner radius 16 (matches Figma / IB: 146x146, radius 16)
        if let iv = Busimageview {
            iv.layer.cornerRadius = 16
            iv.clipsToBounds = true
            iv.contentMode = .scaleAspectFill
        }
        
        // Student — circular
        if let iv = Studentprofileimageview, iv.bounds.height > 0 {
            iv.layer.cornerRadius = iv.bounds.height / 2
        }
        
        CollectionView?.collectionViewLayout.invalidateLayout()
        CollectionView2?.collectionViewLayout.invalidateLayout()
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
        print("📞 Call driver button tapped")
        delegate?.didTapCallDriver()
    }

    // MARK: - Image View Setup
    private func setupImageViews() {
        // Driver — circular avatar
        DriverImageview?.contentMode = .scaleAspectFill
        DriverImageview?.clipsToBounds = true
        DriverImageview?.layer.cornerRadius = (DriverImageview?.bounds.height ?? 40) / 2
        setDriverPlaceholder()

        // Bus — square fill image (146x146, corner radius 16)
        Busimageview?.contentMode = .scaleAspectFill
        Busimageview?.clipsToBounds = true
        Busimageview?.layer.cornerRadius = 16
        Busimageview?.layer.masksToBounds = true
        Busimageview?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        setBusPlaceholder()

        // Student — circular avatar
        Studentprofileimageview?.contentMode = .scaleAspectFill
        Studentprofileimageview?.clipsToBounds = true
        Studentprofileimageview?.layer.cornerRadius = (Studentprofileimageview?.bounds.height ?? 50) / 2
        setStudentPlaceholder()
    }

    private func setDriverPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        DriverImageview?.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        DriverImageview?.tintColor = .systemGray3
        DriverImageview?.contentMode = .scaleAspectFill
    }

    // No default bus image. Shows empty background until API image loads.
    private func setBusPlaceholder() {
        Busimageview?.image = nil
        Busimageview?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        Busimageview?.tintColor = nil
        Busimageview?.contentMode = .scaleAspectFill
        Busimageview?.clipsToBounds = true
        Busimageview?.layer.cornerRadius = 16
    }

    // Student placeholder — gray person icon until real image loads
    private func setStudentPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        Studentprofileimageview?.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        Studentprofileimageview?.tintColor = .systemGray3
        Studentprofileimageview?.backgroundColor = .systemGray6
        Studentprofileimageview?.contentMode = .scaleAspectFill
    }

    // MARK: - Generic Remote Image Loader
    private func loadImage(
        urlString: String?,
        into imageView: UIImageView?,
        placeholder: () -> Void,
        taskStore: inout URLSessionDataTask?,
        isBusImage: Bool = false
    ) {
        placeholder()

        guard var raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return
        }

        // Auto-convert http to https to prevent ATS blocks
        if raw.hasPrefix("http://") {
            raw = raw.replacingOccurrences(of: "http://", with: "https://")
        }

        guard let url = URL(string: raw) else {
            print("❌ Invalid URL string: \(raw)")
            return
        }

        let cacheKey = NSString(string: url.absoluteString)

        // Cache hit
        if let cached = dashImageCache.object(forKey: cacheKey) {
            applyLoadedImage(cached, to: imageView, isBusImage: isBusImage)
            return
        }

        taskStore?.cancel()

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("❌ Failed to download image from \(url): \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to decode image data from \(url)")
                return
            }

            dashImageCache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                self?.applyLoadedImage(image, to: imageView, isBusImage: isBusImage)
            }
        }
        taskStore = task
        task.resume()
    }

    /// Applies downloaded/cached image with correct fill style
    private func applyLoadedImage(_ image: UIImage, to imageView: UIImageView?, isBusImage: Bool) {
        guard let imageView = imageView else { return }
        
        imageView.tintColor = nil
        imageView.backgroundColor = .clear
        imageView.image = image.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFill   // ✅ FILL the frame
        imageView.clipsToBounds = true
        
        if isBusImage {
            // Square rounded rect — matches IB 146x146 + corner radius 16
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
        }
    }

    // MARK: - Convert 24-Hour Time to 12-Hour AM/PM
    private func formatTimeTo12Hour(_ timeString: String?) -> String {
        guard var value = timeString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return "N/A"
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "hh:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let upper = value.uppercased()
        if upper.contains("AM") || upper.contains("PM") {
            let ampmFormats = ["hh:mm a", "h:mm a", "hh:mm:ss a", "h:mm:ss a", "hh:mma", "h:mma"]
            for format in ampmFormats {
                let parser = DateFormatter()
                parser.locale = Locale(identifier: "en_US_POSIX")
                parser.dateFormat = format
                if let date = parser.date(from: value) {
                    return outputFormatter.string(from: date)
                }
            }
            return upper
                .replacingOccurrences(of: "AM", with: " AM")
                .replacingOccurrences(of: "PM", with: " PM")
                .replacingOccurrences(of: "  ", with: " ")
                .trimmingCharacters(in: .whitespaces)
        }

        if let dotIndex = value.firstIndex(of: ".") {
            value = String(value[..<dotIndex])
        }

        let inputFormats = ["HH:mm:ss", "H:mm:ss", "HH:mm", "H:mm"]
        for format in inputFormats {
            let parser = DateFormatter()
            parser.locale = Locale(identifier: "en_US_POSIX")
            parser.dateFormat = format
            if let date = parser.date(from: value) {
                return outputFormatter.string(from: date)
            }
        }

        return "N/A"
    }

    // MARK: - ✅ Configure Bus & Driver Details from API
    func configureBusDetails(_ busData: StudentBusData?) {

        // Driver name
        DrivernameLabel.text =
            busData?.driver?.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? busData?.driver?.name
            : "N/A"

        // Bus number
        BusnumberLabel.text =
            busData?.bus?.vehicleNumber?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? busData?.bus?.vehicleNumber
            : "N/A"

        // ✅ 1. Load Driver Image from Bus API
        loadImage(
            urlString: busData?.driver?.profileImage,
            into: DriverImageview,
            placeholder: { [weak self] in self?.setDriverPlaceholder() },
            taskStore: &driverImageTask,
            isBusImage: false
        )

        // ✅ 2. Load Bus Image from Bus API — FILL square image view (corner radius 16)
        let busImageURL = busData?.bus?.image
            ?? busData?.bus?.busImage
            ?? busData?.bus?.vehicleImage
            ?? busData?.bus?.vehiclePhoto
            ?? busData?.bus?.busPhoto
            ?? busData?.bus?.photo

        print("🚌 Bus Image URL: \(busImageURL ?? "NIL")")

        loadImage(
            urlString: busImageURL,
            into: Busimageview,
            placeholder: { [weak self] in self?.setBusPlaceholder() },
            taskStore: &busImageTask,
            isBusImage: true
        )

        // ✅ 3. Load Student Image — saved by StudentprofileVC (STUDENT_PHOTO_URL)
        let studentPhotoURL = UserDefaults.standard.string(forKey: "STUDENT_PHOTO_URL")
            ?? UserManager.shared.resolvedStudentPhotoURL
        print("🧑‍🎓 Student Image URL (saved): \(studentPhotoURL.isEmpty ? "NIL / Not Found" : studentPhotoURL)")

        loadImage(
            urlString: studentPhotoURL.isEmpty ? nil : studentPhotoURL,
            into: Studentprofileimageview,
            placeholder: { [weak self] in self?.setStudentPlaceholder() },
            taskStore: &studentImageTask,
            isBusImage: false
        )
    }

    // MARK: - ✅ Configure Route Details (Pickup & Drop) from API
    func configureRouteDetails(_ busData: StudentBusData?) {

        if let pickupStopName = busData?.pickupStop?.stopName,
           !pickupStopName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            PickuplocationLabel.text = pickupStopName
        } else {
            PickuplocationLabel.text = "N/A"
        }

        let pickupTime = busData?.pickupStop?.pickupTime
        PickupTime.text = formatTimeTo12Hour(pickupTime)
        PickuptimeLabel.text = formatTimeTo12Hour(pickupTime)

        if let dropStopName = busData?.dropStop?.stopName,
           !dropStopName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DroplocationLabel.text = dropStopName
        } else {
            DroplocationLabel.text = "N/A"
        }

        let dropTime = busData?.dropStop?.dropTime
        DropTime.text = formatTimeTo12Hour(dropTime)

        if let duration = busData?.route?.estimatedDuration {
            DurationLabel.text = "\(duration) Min"
        } else {
            DurationLabel.text = "N/A"
        }

        buildJourneyItems(busData)
        CollectionView2.reloadData()
    }

    // MARK: - Build Today's Journey Items From Route API
    private func buildJourneyItems(_ busData: StudentBusData?) {
        journeyItems.removeAll()

        let pickupStop = busData?.pickupStop
        let dropStop = busData?.dropStop
        let route = busData?.route

        // 1. Pickup
        journeyItems.append(JourneyItem(
            title: "Pickup",
            time: formatTimeTo12Hour(pickupStop?.pickupTime),
            location: pickupStop?.stopName ?? "N/A",
            imageName: "icon 47",
            iconTintColor: UIColor(red: 22/255, green: 163/255, blue: 74/255, alpha: 1.0),
            iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
        ))

        // 2. On Route
        let destinationName = route?.destination ?? dropStop?.stopName ?? "School"
        journeyItems.append(JourneyItem(
            title: "On Route",
            time: "",
            location: "Towards \(destinationName)",
            imageName: "icon 48",
            iconTintColor: UIColor(red: 22/255, green: 163/255, blue: 74/255, alpha: 1.0),
            iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
        ))

        // 3. School
        journeyItems.append(JourneyItem(
            title: "School",
            time: formatTimeTo12Hour(dropStop?.dropTime),
            location: dropStop?.stopName ?? route?.destination ?? "School",
            imageName: "icon 49",
            iconTintColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0),
            iconBackgroundColor: UIColor(red: 219/255, green: 234/255, blue: 254/255, alpha: 1.0)
        ))
    }

    // MARK: - Top CollectionView Setup
    private func setupTopCollectionView() {
        guard let cv = CollectionView else { return }

        cv.delegate   = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.bounces         = false
        cv.tag = 1

        cv.register(
            UINib(nibName: "TRNSPTdashbordCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TRNSPTdashbordCollectionViewCell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .horizontal
        layout.minimumLineSpacing      = cardSpacing
        layout.minimumInteritemSpacing = cardSpacing
        layout.sectionInset = UIEdgeInsets(top: 8, left: sideInset, bottom: 8, right: sideInset)
        cv.collectionViewLayout = layout

        cv.reloadData()
    }

    // MARK: - Journey CollectionView Setup
    private func setupJourneyCollectionView() {
        guard let cv = CollectionView2 else { return }

        cv.delegate   = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.bounces         = false
        cv.tag = 2

        cv.register(
            UINib(nibName: "TRNSPTTodayJourneyCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TRNSPTTodayJourneyCollectionViewCell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .vertical
        layout.minimumLineSpacing      = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset            = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        cv.collectionViewLayout        = layout

        cv.reloadData()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension TRNSPTdashbordUITableViewCell1: UICollectionViewDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2 {
            return journeyItems.count
        }
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TRNSPTTodayJourneyCollectionViewCell",
                for: indexPath
            ) as! TRNSPTTodayJourneyCollectionViewCell

            let item = journeyItems[indexPath.item]
            cell.configure(
                title:            item.title,
                time:             item.time,
                location:         item.location,
                imageName:        item.imageName,
                iconTint:         item.iconTintColor,
                iconBackground:   item.iconBackgroundColor
            )
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TRNSPTdashbordCollectionViewCell",
            for: indexPath
        ) as! TRNSPTdashbordCollectionViewCell

        let item = items[indexPath.item]
        cell.configure(
            title:           item.title,
            description:     item.description,
            imageName:       item.imageName,
            backgroundColor: item.backgroundColor,
            iconTint:        item.iconTintColor
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView.tag == 2 {
            return CGSize(width: collectionView.bounds.width, height: 48)
        }

        let cardCount: CGFloat    = CGFloat(items.count)
        let totalSpacing: CGFloat = cardSpacing * (cardCount - 1)
        let totalInsets: CGFloat  = sideInset * 2

        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets
        let cardWidth = floor(availableWidth / cardCount)

        return CGSize(width: cardWidth, height: cardHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        if collectionView.tag == 2 {
            print("🛣️ Journey selected: \(journeyItems[indexPath.item].title)")
            return
        }

        let selectedTitle = items[indexPath.item].title
        print("🚌 Module selected: \(selectedTitle)")

        switch selectedTitle {
        case "Live\nTracking":
            delegate?.didTapLiveTracking()

        case "Fee\nModule":
            delegate?.didTapFeeModule()

        case "Driver\nContact":
            delegate?.didTapDriverContact()

        case "Pickup&Drop\nDetails":
            delegate?.didTapPickupandDrop()

        default:
            break
        }
    }
}
