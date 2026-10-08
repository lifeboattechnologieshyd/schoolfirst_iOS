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
    func didTapCallAttendant()
}

// Shared image cache for dashboard cell
private let dashImageCache = NSCache<NSString, UIImage>()

class TRNSPTdashbordUITableViewCell1: UITableViewCell {
    @IBOutlet weak var Pickupimageview: UIImageView!
    
    // ⚠️ IMPORTANT: Changed from NSLayoutConstraint to UIView to apply background color.
    // Please reconnect this in your Storyboard/XIB to the actual Line View.
    @IBOutlet weak var DropStatusview: UIView!
    @IBOutlet weak var PickupstatusView: UIView!
    
    @IBOutlet weak var OnroutestatusLabel: UILabel!
    @IBOutlet weak var pickupimage: UIImageView!
    @IBOutlet weak var DropbackroundView: UIView!
    @IBOutlet weak var OnroutbackroundView: UIView!
    @IBOutlet weak var PickupbackgroundView: UIView!
   
    @IBOutlet weak var AttendantnameLabel: UILabel!
    @IBOutlet weak var AttendantImageview: UIImageView!
    @IBOutlet weak var DriverImageview: UIImageView!
    @IBOutlet weak var DroplocationView: UIView!
    @IBOutlet weak var DropTime: UILabel!
    
    @IBOutlet weak var ETA: UILabel!
    @IBOutlet weak var OnrouteView: UIView!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var PickuplocationView: UIView!
    @IBOutlet weak var DroplocationLabel: UILabel!
    @IBOutlet weak var PickuplocationLabel: UILabel!
    @IBOutlet weak var PickuptimeLabel: UILabel!
    
    @IBOutlet weak var Callattendantbutton: UIButton!
    @IBOutlet weak var Studentprofileimageview: UIImageView!
    @IBOutlet weak var CalldriverButton: UIButton!
    @IBOutlet weak var Busimageview: UIImageView!
    @IBOutlet weak var DrivernameLabel: UILabel!
    @IBOutlet weak var BusnumberLabel: UILabel!
    @IBOutlet weak var StudentgradeLbl: UILabel!
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var CollectionView2: UICollectionView!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var TodaysjourneyLabel: UILabel!
    
    weak var delegate: TRNSPTdashbordCell1Delegate?

    private var driverImageTask: URLSessionDataTask?
    private var attendantImageTask: URLSessionDataTask?
    private var busImageTask: URLSessionDataTask?
    private var studentImageTask: URLSessionDataTask?

    private let cardSpacing: CGFloat   = 2
    private let sideInset: CGFloat     = 14
    private let cardHeight: CGFloat    = 126

    private struct TransportItem {
        let title: String
        let description: String
        let imageName: String
        let backgroundColor: UIColor
        let borderColor: UIColor
        let iconTintColor: UIColor
    }

    private let items: [TransportItem] = [
        TransportItem(
            title: "Live\nTracking",
            description: "Track bus live",
            imageName: "icon 42",
            backgroundColor: UIColor(red: 220/255, green: 242/255, blue: 230/255, alpha: 1.0),
            borderColor:     UIColor(red: 180/255, green: 220/255, blue: 195/255, alpha: 1.0),
            iconTintColor:   UIColor(red:  46/255, green: 160/255, blue:  90/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Driver\nContact",
            description: "Call or message",
            imageName: "icon 43",
            backgroundColor: UIColor(red: 255/255, green: 243/255, blue: 230/255, alpha: 1.0),
            borderColor:     UIColor(red: 255/255, green: 220/255, blue: 185/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 230/255, green: 120/255, blue:  40/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Fee\nModule",
            description: "Manage Payments",
            imageName: "icon44",
            backgroundColor: UIColor(red: 240/255, green: 232/255, blue: 250/255, alpha: 1.0),
            borderColor:     UIColor(red: 215/255, green: 195/255, blue: 235/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 155/255, green: 100/255, blue: 200/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Pickup&Drop\nDetails",
            description: "View timings",
            imageName: "icon 45",
            backgroundColor: UIColor(red: 252/255, green: 232/255, blue: 242/255, alpha: 1.0),
            borderColor:     UIColor(red: 240/255, green: 195/255, blue: 220/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 220/255, green:  80/255, blue: 150/255, alpha: 1.0)
        )
    ]

    private struct JourneyItem {
        let title: String
        let time: String
        let location: String
        let imageName: String
        let iconTintColor: UIColor
        let iconBackgroundColor: UIColor
    }

    private var journeyItems: [JourneyItem] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        StudentnameLbl.text  = UserManager.shared.resolvedStudentName
        StudentgradeLbl.text = UserManager.shared.resolvedGradeSection
        selectionStyle = .none
        
        setupFonts()
        setupImageViews()
        setupCallButton()
        setupTopCollectionView()
        setupJourneyCollectionView()
    }

    private func setupFonts() {
        StudentnameLbl?.font = .hankenBold(size: 16)
        StudentgradeLbl?.font = .hankenMedium(size: 12)
        BusnumberLabel?.font = .hankenBold(size: 18)
        DrivernameLabel?.font = .hankenSemiBold(size: 14)
        AttendantnameLabel?.font = .hankenSemiBold(size: 14)
        PickuplocationLabel?.font = .hankenSemiBold(size: 11)
        DroplocationLabel?.font = .hankenSemiBold(size: 11)
        PickuptimeLabel?.font = .hankenMedium(size: 10)
        ETA?.font = .hankenMedium(size: 18)
        DropTime?.font = .hankenMedium(size: 10)
        DurationLabel?.font = .hankenMedium(size: 10)
        TodaysjourneyLabel?.font = .hankenBold(size: 12)
        OnroutestatusLabel?.font = .hankenBold(size: 14) // Applied proper Hanken font
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        driverImageTask?.cancel()
        attendantImageTask?.cancel()
        busImageTask?.cancel()
        studentImageTask?.cancel()
        driverImageTask = nil
        attendantImageTask = nil
        busImageTask = nil
        studentImageTask = nil
        setDriverPlaceholder()
        setAttendantPlaceholder()
        setBusPlaceholder()
        setStudentPlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let iv = DriverImageview, iv.bounds.height > 0 { iv.layer.cornerRadius = iv.bounds.height / 2 }
        if let iv = AttendantImageview, iv.bounds.height > 0 { iv.layer.cornerRadius = iv.bounds.height / 2 }
        if let iv = Busimageview { iv.layer.cornerRadius = 16; iv.clipsToBounds = true; iv.contentMode = .scaleAspectFill }
        if let iv = Studentprofileimageview, iv.bounds.height > 0 { iv.layer.cornerRadius = iv.bounds.height / 2 }
        
        // Circular backgrounds for timeline
        PickupbackgroundView?.layer.cornerRadius = (PickupbackgroundView?.bounds.height ?? 32) / 2
        OnroutbackroundView?.layer.cornerRadius = (OnroutbackroundView?.bounds.height ?? 32) / 2
        DropbackroundView?.layer.cornerRadius = (DropbackroundView?.bounds.height ?? 32) / 2
        
        CollectionView?.collectionViewLayout.invalidateLayout()
        CollectionView2?.collectionViewLayout.invalidateLayout()
    }

    private func setupCallButton() {
        CalldriverButton?.addTarget(self, action: #selector(callDriverButtonTapped), for: .touchUpInside)
        Callattendantbutton?.addTarget(self, action: #selector(callAttendantButtonTapped), for: .touchUpInside)
    }

    @objc private func callDriverButtonTapped() { delegate?.didTapCallDriver() }
    @objc private func callAttendantButtonTapped() { delegate?.didTapCallAttendant() }

    private func setupImageViews() {
        DriverImageview?.contentMode = .scaleAspectFill
        DriverImageview?.clipsToBounds = true
        setDriverPlaceholder()

        AttendantImageview?.contentMode = .scaleAspectFill
        AttendantImageview?.clipsToBounds = true
        setAttendantPlaceholder()

        Busimageview?.contentMode = .scaleAspectFill
        Busimageview?.clipsToBounds = true
        Busimageview?.layer.cornerRadius = 16
        Busimageview?.layer.masksToBounds = true
        Busimageview?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        setBusPlaceholder()

        Studentprofileimageview?.contentMode = .scaleAspectFill
        Studentprofileimageview?.clipsToBounds = true
        setStudentPlaceholder()
    }

    private func setDriverPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        DriverImageview?.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        DriverImageview?.tintColor = .systemGray3
        DriverImageview?.contentMode = .scaleAspectFill
    }
    
    private func setAttendantPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        AttendantImageview?.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        AttendantImageview?.tintColor = .systemGray3
        AttendantImageview?.contentMode = .scaleAspectFill
    }

    private func setBusPlaceholder() {
        Busimageview?.image = nil
        Busimageview?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        Busimageview?.contentMode = .scaleAspectFill
        Busimageview?.clipsToBounds = true
        Busimageview?.layer.cornerRadius = 16
    }

    private func setStudentPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        Studentprofileimageview?.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        Studentprofileimageview?.tintColor = .systemGray3
        Studentprofileimageview?.backgroundColor = .systemGray6
        Studentprofileimageview?.contentMode = .scaleAspectFill
    }

    private func loadImage(urlString: String?, into imageView: UIImageView?, placeholder: () -> Void, taskStore: inout URLSessionDataTask?, isBusImage: Bool = false) {
        placeholder()
        guard var raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return }
        if raw.hasPrefix("http://") { raw = raw.replacingOccurrences(of: "http://", with: "https://") }
        guard let url = URL(string: raw) else { return }
        let cacheKey = NSString(string: url.absoluteString)
        if let cached = dashImageCache.object(forKey: cacheKey) {
            applyLoadedImage(cached, to: imageView, isBusImage: isBusImage)
            return
        }
        taskStore?.cancel()
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard error == nil, let data = data, let image = UIImage(data: data) else { return }
            dashImageCache.setObject(image, forKey: cacheKey)
            DispatchQueue.main.async { self?.applyLoadedImage(image, to: imageView, isBusImage: isBusImage) }
        }
        taskStore = task
        task.resume()
    }

    private func applyLoadedImage(_ image: UIImage, to imageView: UIImageView?, isBusImage: Bool) {
        guard let imageView = imageView else { return }
        imageView.tintColor = nil
        imageView.backgroundColor = .clear
        imageView.image = image.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if isBusImage { imageView.layer.cornerRadius = 16; imageView.layer.masksToBounds = true }
    }

    private func formatTimeTo12Hour(_ timeString: String?) -> String {
        guard var value = timeString?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return "N/A" }
        let outputFormatter = DateFormatter(); outputFormatter.dateFormat = "hh:mm a"; outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let upper = value.uppercased()
        if upper.contains("AM") || upper.contains("PM") {
            let ampmFormats = ["hh:mm a", "h:mm a", "hh:mm:ss a", "h:mm:ss a", "hh:mma", "h:mma"]
            for format in ampmFormats {
                let parser = DateFormatter(); parser.locale = Locale(identifier: "en_US_POSIX"); parser.dateFormat = format
                if let date = parser.date(from: value) { return outputFormatter.string(from: date) }
            }
            return upper.replacingOccurrences(of: "AM", with: " AM").replacingOccurrences(of: "PM", with: " PM").replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
        }
        if let dotIndex = value.firstIndex(of: ".") { value = String(value[..<dotIndex]) }
        let inputFormats = ["HH:mm:ss", "H:mm:ss", "HH:mm", "H:mm"]
        for format in inputFormats {
            let parser = DateFormatter(); parser.locale = Locale(identifier: "en_US_POSIX"); parser.dateFormat = format
            if let date = parser.date(from: value) { return outputFormatter.string(from: date) }
        }
        return "N/A"
    }
    
    // ✅ UPDATED: Configures the UI status lines, checkmarks, background circles, AND OnroutestatusLabel based on API response
    // ✅ UPDATED: Configures UI lines, checkmarks, backgrounds and statuses dynamically based on the student's actual stop arrival status
    func configureTripStatus(_ busData: StudentBusData?) {
        guard let busData = busData else {
            resetTimelineToGray(message: "Bus Not Started")
            return
        }

        let rawStatus = (busData.tripStatus ?? "").lowercased()
        let isActive = ["active", "started", "live", "running", "on_route"].contains(rawStatus)
        let isCompleted = ["completed", "complete", "finished", "ended", "done"].contains(rawStatus)

        let shift = (busData.tripShift ?? busData.route?.shift ?? "MORNING").uppercased()
        let tripType = (busData.tripType ?? "").uppercased()
        let isEvening = shift == "EVENING" || shift == "AFTERNOON" || tripType == "DROP"

        let green = UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)
        let gray  = UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 1.0)

        let checkCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let checkImg = UIImage(systemName: "checkmark", withConfiguration: checkCfg)
        let pinImg   = UIImage(systemName: "mappin.and.ellipse")

        func isStopReached(_ stop: RouteStop?) -> Bool {
            guard let stop = stop else { return false }
            let s = (stop.status ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let reachedTime = (stop.reachedTime ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !reachedTime.isEmpty { return true }
            let keywords = ["reach", "complete", "done", "arriv", "pick", "drop", "finish", "success", "visited", "passed"]
            return keywords.contains { s.contains($0) } && s != "pending" && s != "scheduled"
        }

        func findStop(id: String?, name: String?, code: String? = nil) -> RouteStop? {
            busData.routeStops?.first(where: { stop in
                if let id, let sid = stop.id, id == sid { return true }
                if let code, let sc = stop.stopCode, code == sc { return true }
                if let name, let sn = stop.stopName, sn.lowercased() == name.lowercased() { return true }
                return false
            })
        }

        func isPassedByOrder(_ target: RouteStop?) -> Bool {
            guard let targetOrder = target?.stopOrder else { return false }
            return busData.routeStops?.contains(where: { stop in
                guard let order = stop.stopOrder, order >= targetOrder else { return false }
                return isStopReached(stop)
            }) ?? false
        }

        func applyPickupIcon(reached: Bool) {
            let img = reached ? checkImg : pinImg
            let tint: UIColor = reached ? .white : .systemGray
            pickupimage?.image = img
            pickupimage?.tintColor = tint
            Pickupimageview?.image = img
            Pickupimageview?.tintColor = tint
        }

        func setCircle(_ v: UIView?, _ color: UIColor) {
            v?.backgroundColor = color
            v?.clipsToBounds = true
        }

        func setLine(_ v: UIView?, _ color: UIColor) {
            v?.backgroundColor = color
            v?.layer.backgroundColor = color.cgColor
        }

        // CASE 1: Trip completed
        if isCompleted {
            OnroutestatusLabel?.text = "Completed"
            applyPickupIcon(reached: true)
            setCircle(PickupbackgroundView, green)
            setCircle(OnroutbackroundView, green)
            setCircle(DropbackroundView, green)
            setLine(PickupstatusView, green)
            setLine(DropStatusview, green)
            return
        }

        // CASE 2: Bus not started
        guard isActive else {
            resetTimelineToGray(message: "Bus Not Started")
            return
        }

        // CASE 3: Active trip
        OnroutestatusLabel?.text = "On Route"

        let schoolStop = busData.routeStops?.first(where: { $0.stopType?.uppercased() == "SCHOOL" })
        let schoolName = schoolStop?.stopName ?? busData.route?.destination ?? "School"

        let startStop: RouteStop?
        if isEvening {
            startStop = schoolStop
        } else {
            startStop = findStop(
                id: busData.pickupStop?.id,
                name: busData.pickupStop?.stopName,
                code: busData.pickupStop?.stopCode
            ) ?? findStop(id: nil, name: busData.pickupStop?.stopName)
        }

        let endStop: RouteStop?
        if isEvening {
            endStop = findStop(
                id: busData.dropStop?.id,
                name: busData.dropStop?.stopName,
                code: busData.dropStop?.stopCode
            )
        } else {
            endStop = schoolStop
        }

        let startReached = isStopReached(startStop) || isPassedByOrder(startStop)
        let endReached   = isStopReached(endStop)   || isPassedByOrder(endStop)

        #if DEBUG
        print("""
        🚌 Timeline Debug
          start: \(startStop?.stopName ?? "nil") status=\(startStop?.status ?? "nil")
          startReached: \(startReached) endReached: \(endReached)
        """)
        #endif

        if endReached {
            applyPickupIcon(reached: true)
            setCircle(PickupbackgroundView, green)
            setCircle(OnroutbackroundView, green)
            setCircle(DropbackroundView, green)
            setLine(PickupstatusView, green)
            setLine(DropStatusview, green)

        } else if startReached {
            // Student stop reached → Pickup + On Route green
            applyPickupIcon(reached: true)
            setCircle(PickupbackgroundView, green)
            setLine(PickupstatusView, green)
            setCircle(OnroutbackroundView, green)
            setLine(DropStatusview, gray)
            setCircle(DropbackroundView, gray)

        } else {
            // Bus running, student stop NOT reached → everything gray (including On Route)
            applyPickupIcon(reached: false)
            setCircle(PickupbackgroundView, gray)
            setLine(PickupstatusView, gray)
            setCircle(OnroutbackroundView, gray)   // ✅ On Route green only after stop reached
            setLine(DropStatusview, gray)
            setCircle(DropbackroundView, gray)
        }
    }

    private func resetTimelineToGray(message: String = "Bus Not Started") {
        let gray = UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 1.0)
        let pin  = UIImage(systemName: "mappin.and.ellipse")

        OnroutestatusLabel?.text = message

        pickupimage?.image = pin
        pickupimage?.tintColor = .systemGray
        Pickupimageview?.image = pin
        Pickupimageview?.tintColor = .systemGray

        PickupbackgroundView?.backgroundColor = gray
        OnroutbackroundView?.backgroundColor = gray
        DropbackroundView?.backgroundColor = gray
        PickupstatusView?.backgroundColor = gray
        DropStatusview?.backgroundColor = gray
        PickupstatusView?.layer.backgroundColor = gray.cgColor
        DropStatusview?.layer.backgroundColor = gray.cgColor
    }
    func configureBusDetails(_ busData: StudentBusData?) {
        
        DrivernameLabel.text = busData?.driver?.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? busData?.driver?.name
            : "N/A"
        
        AttendantnameLabel.text = busData?.attendant?.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? busData?.attendant?.name
            : "N/A"

        // ✅ Bus Number + Registration Number configure
        let vehicleNumber = busData?.bus?.vehicleNumber?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let registrationNumber = busData?.bus?.registrationNumber?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        BusnumberLabel.text = registrationNumber.isEmpty ? (vehicleNumber.isEmpty ? "N/A" : vehicleNumber) : registrationNumber

        loadImage(
            urlString: busData?.driver?.profileImage,
            into: DriverImageview,
            placeholder: { [weak self] in self?.setDriverPlaceholder() },
            taskStore: &driverImageTask,
            isBusImage: false
        )
        
        loadImage(
            urlString: busData?.attendant?.profileImage,
            into: AttendantImageview,
            placeholder: { [weak self] in self?.setAttendantPlaceholder() },
            taskStore: &attendantImageTask,
            isBusImage: false
        )

        let busImageURL = busData?.bus?.image
            ?? busData?.bus?.busImage
            ?? busData?.bus?.vehicleImage
            ?? busData?.bus?.vehiclePhoto
            ?? busData?.bus?.busPhoto
            ?? busData?.bus?.photo
        
        loadImage(
            urlString: busImageURL,
            into: Busimageview,
            placeholder: { [weak self] in self?.setBusPlaceholder() },
            taskStore: &busImageTask,
            isBusImage: true
        )

        let studentPhotoURL = UserManager.shared.resolvedStudentPhotoURL
        
        loadImage(
            urlString: studentPhotoURL.isEmpty ? nil : studentPhotoURL,
            into: Studentprofileimageview,
            placeholder: { [weak self] in self?.setStudentPlaceholder() },
            taskStore: &studentImageTask,
            isBusImage: false
        )
    }
    
    // ✅ UPDATED: Configures Pickup and Drop labels safely matching MORNING or EVENING shifts
    // ✅ UPDATED: Calculates dynamic ETA and shows "Reached" when stop is completed
    // ✅ UPDATED: DurationLabel → ETA only | PickuptimeLabel → Pickup TIME | DropTime → Drop TIME
    // ✅ UPDATED: PickuptimeLabel → Scheduled API time ONLY | DurationLabel → ETA
    // ✅ UPDATED: Accepts liveETASeconds. Maps ETA directly to UI
    func configureRouteDetails(_ busData: StudentBusData?, liveETASeconds: TimeInterval? = nil) {
        let shift = (busData?.route?.shift ?? "MORNING").uppercased()
        let isEvening = shift == "EVENING"
        
        // 1. Identify School and Student Stops
        let schoolStop = busData?.routeStops?.first(where: { $0.stopType?.uppercased() == "SCHOOL" })
        let schoolName = schoolStop?.stopName ?? "School"
        
        let pickupStopName = isEvening ? schoolName : (busData?.pickupStop?.stopName ?? "Home Stop")
        let pickupTimeValue = isEvening ? (schoolStop?.pickupTime ?? "05:50:00") : (busData?.pickupStop?.pickupTime ?? "07:50:00")
        
        let dropStopName = isEvening ? (busData?.dropStop?.stopName ?? "Home") : schoolName
        let dropTimeValue = isEvening ? (busData?.dropStop?.dropTime ?? "18:20:00") : (schoolStop?.dropTime ?? "08:30:00")
        
        PickuplocationLabel.text = pickupStopName.isEmpty == false ? pickupStopName : (isEvening ? "School" : "Home Stop")
        DroplocationLabel.text = dropStopName.isEmpty == false ? dropStopName : (isEvening ? "Home" : "School")
        PickuptimeLabel.text = formatTimeTo12Hour(pickupTimeValue)
        DropTime.text = formatTimeTo12Hour(dropTimeValue)
        
        // 2. Find Student's Target Stop
        let targetStopId = isEvening ? busData?.dropStop?.id : busData?.pickupStop?.id
        let studentRouteStop = busData?.routeStops?.first(where: {
            ($0.id != nil && $0.id == targetStopId) ||
            ($0.stopName?.lowercased() == (isEvening ? dropStopName : pickupStopName).lowercased())
        })
        
        let stopStatus = (studentRouteStop?.status ?? "").lowercased()
        let hasReachedTime = !(studentRouteStop?.reachedTime ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isStopReached = stopStatus == "reached" || stopStatus == "completed" || hasReachedTime
        
        // 3. Configure ETA & DurationLabel
        if isStopReached {
            // 🟢 Stop REACHED
            ETA.text = "Reached"
            DurationLabel.text = "Reached"
            DurationLabel.textColor = .label
        } else {
            // 🟡 Check if we have LIVE MapKit ETA
            if let liveSeconds = liveETASeconds {
                // Live location available!
                let minutes = max(1, Int(liveSeconds / 60))
                let etaDate = Date().addingTimeInterval(liveSeconds)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                
                ETA.text = formatter.string(from: etaDate)
                DurationLabel.text = "\(minutes) Min (Live)"
                
                // Color it Green to indicate it's real-time
                DurationLabel.textColor = UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)
                
            } else {
                // Static API fallback ETA
                DurationLabel.textColor = .label
                let travelMinutes = studentRouteStop?.estimatedTravelTime ?? busData?.route?.estimatedDuration
                
                if let minutes = travelMinutes, minutes > 0 {
                    let etaDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm a"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    ETA.text = formatter.string(from: etaDate)
                    DurationLabel.text = "\(minutes) Min"
                } else {
                    ETA.text = formatTimeTo12Hour(pickupTimeValue)
                    DurationLabel.text = "N/A"
                }
            }
        }
        
        // 4. Reload Timeline
        buildJourneyItems(busData, isEvening: isEvening, schoolStop: schoolStop)
        CollectionView2.reloadData()
    }
    // ✅ UPDATED: Rebuilds Journey timeline points based on MORNING / EVENING logic
    private func buildJourneyItems(_ busData: StudentBusData?, isEvening: Bool, schoolStop: RouteStop?) {
        journeyItems.removeAll()
        let schoolName = schoolStop?.stopName ?? "School"
        
        if isEvening {
            // Evening Flow: School (Departure) -> On Route (Towards Home) -> Drop (Home Stop Arrival)
            let schoolTime = formatTimeTo12Hour(schoolStop?.pickupTime ?? "17:50:00")
            let homeStopName = busData?.dropStop?.stopName ?? "Home Stop"
            let homeTime = formatTimeTo12Hour(busData?.dropStop?.dropTime ?? "18:20:00")
            
            journeyItems.append(JourneyItem(
                title: "School",
                time: schoolTime,
                location: schoolName,
                imageName: "icon 47",
                iconTintColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0),
                iconBackgroundColor: UIColor(red: 219/255, green: 234/255, blue: 254/255, alpha: 1.0)
            ))
            
            journeyItems.append(JourneyItem(
                title: "On Route",
                time: "",
                location: "Towards \(homeStopName)",
                imageName: "icon 48",
                iconTintColor: UIColor(red: 22/255, green: 163/255, blue: 74/255, alpha: 1.0),
                iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
            ))
            
            journeyItems.append(JourneyItem(
                title: "Drop",
                time: homeTime,
                location: homeStopName,
                imageName: "icon 49",
                iconTintColor: UIColor(red: 22/255, green: 163/255, blue: 74/255, alpha: 1.0),
                iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
            ))
        } else {
            // Morning Flow (Default): Pickup (Home Stop) -> On Route (Towards School) -> School (Arrival)
            let homeStopName = busData?.pickupStop?.stopName ?? "Home Stop"
            let homeTime = formatTimeTo12Hour(busData?.pickupStop?.pickupTime ?? "07:50:00")
            let schoolTime = formatTimeTo12Hour(schoolStop?.dropTime ?? "08:30:00")
            
            journeyItems.append(JourneyItem(
                title: "Pickup",
                time: homeTime,
                location: homeStopName,
                imageName: "icon 47",
                iconTintColor: UIColor(red: 22/255, green: 163/255, blue: 74/255, alpha: 1.0),
                iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
            ))
            
            journeyItems.append(JourneyItem(
                title: "On Route",
                time: "",
                location: "Towards \(schoolName)",
                imageName: "icon 48",
                iconTintColor: UIColor(red: 22/255, green: 163/255, blue: 74/255, alpha: 1.0),
                iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
            ))
            
            journeyItems.append(JourneyItem(
                title: "School",
                time: schoolTime,
                location: schoolName,
                imageName: "icon 49",
                iconTintColor: UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0),
                iconBackgroundColor: UIColor(red: 219/255, green: 234/255, blue: 254/255, alpha: 1.0)
            ))
        }
    }

    private func setupTopCollectionView() {
        guard let cv = CollectionView else { return }
        cv.delegate = self; cv.dataSource = self; cv.backgroundColor = .clear; cv.showsHorizontalScrollIndicator = false; cv.isScrollEnabled = false; cv.bounces = false; cv.tag = 1
        cv.register(UINib(nibName: "TRNSPTdashbordCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TRNSPTdashbordCollectionViewCell")
        let layout = UICollectionViewFlowLayout(); layout.scrollDirection = .horizontal; layout.minimumLineSpacing = cardSpacing; layout.minimumInteritemSpacing = cardSpacing; layout.sectionInset = UIEdgeInsets(top: 8, left: sideInset, bottom: 8, right: sideInset); cv.collectionViewLayout = layout; cv.reloadData()
    }

    private func setupJourneyCollectionView() {
        guard let cv = CollectionView2 else { return }
        cv.delegate = self; cv.dataSource = self; cv.backgroundColor = .clear; cv.showsVerticalScrollIndicator = false; cv.isScrollEnabled = false; cv.bounces = false; cv.tag = 2
        cv.register(UINib(nibName: "TRNSPTTodayJourneyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TRNSPTTodayJourneyCollectionViewCell")
        let layout = UICollectionViewFlowLayout(); layout.scrollDirection = .vertical; layout.minimumLineSpacing = 8; layout.minimumInteritemSpacing = 0; layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0); cv.collectionViewLayout = layout; cv.reloadData()
    }
}

extension TRNSPTdashbordUITableViewCell1: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2 { return journeyItems.count }; return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRNSPTTodayJourneyCollectionViewCell", for: indexPath) as! TRNSPTTodayJourneyCollectionViewCell
            let item = journeyItems[indexPath.item]
            cell.configure(title: item.title, time: item.time, location: item.location, imageName: item.imageName, iconTint: item.iconTintColor, iconBackground: item.iconBackgroundColor)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRNSPTdashbordCollectionViewCell", for: indexPath) as! TRNSPTdashbordCollectionViewCell
        let item = items[indexPath.item]
        cell.configure(title: item.title, description: item.description, imageName: item.imageName, backgroundColor: item.backgroundColor, iconTint: item.iconTintColor, borderColor: item.borderColor)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 2 { return CGSize(width: collectionView.bounds.width, height: 48) }
        let cardCount: CGFloat = CGFloat(items.count); let totalSpacing: CGFloat = cardSpacing * (cardCount - 1); let totalInsets: CGFloat = sideInset * 2
        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets; let cardWidth = floor(availableWidth / cardCount)
        return CGSize(width: cardWidth, height: cardHeight)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 2 { return }
        let selectedTitle = items[indexPath.item].title
        switch selectedTitle {
        case "Live\nTracking": delegate?.didTapLiveTracking()
        case "Fee\nModule": delegate?.didTapFeeModule()
        case "Driver\nContact": delegate?.didTapDriverContact()
        case "Pickup&Drop\nDetails": delegate?.didTapPickupandDrop()
        default: break
        }
    }
}
