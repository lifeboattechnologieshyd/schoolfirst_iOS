//
//  TRSPRTpickupanddropVC.swift
//  SchoolFirst
//

import UIKit

class TRSPRTpickupanddropVC: UIViewController {

    @IBOutlet weak var PickupanddropLabel: UILabel!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    @IBOutlet weak var Topview: UIView!
    // 0 = Morning Pickup, 1 = Evening Drop
    private var selectedSegmentIndex: Int = 0

    var busNumber: String?
    var routeCode: String?

    private var busData: StudentBusData?
    private var isLoading = false

    private var displayStops: [RouteStop] {
        let stops = busData?.routeStops ?? []
        let ascending = stops.sorted { ($0.stopOrder ?? 0) < ($1.stopOrder ?? 0) }
        if selectedSegmentIndex == 1 {
            return ascending.reversed()
        }
        return ascending
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchBusData()
        setupTopViewBottomShadowAndBorder()
    }
    private func setupFonts() {
        PickupanddropLabel?.font = .hankenSemiBold(size: 20)
        
    }
    private func setupTopViewBottomShadowAndBorder() {
           guard let topView = Topview else { return }

           // 1. Bottom Shadow Setup
           topView.layer.masksToBounds = false
           topView.layer.shadowColor = UIColor.black.cgColor
           topView.layer.shadowOpacity = 0.08
           topView.layer.shadowOffset = CGSize(width: 0, height: 3)
           topView.layer.shadowRadius = 4.0
           
           // Optimize rendering performance using a precise shadow path along the bottom
           let shadowRect = CGRect(x: 0, y: topView.bounds.height - 2, width: topView.bounds.width, height: 4)
           topView.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath

           // 2. Bottom Border Line Setup
           topView.layer.sublayers?.removeAll(where: { $0.name == "TopViewBottomBorder" })

           let borderHeight: CGFloat = 1.0
           let bottomBorder = CALayer()
           bottomBorder.name = "TopViewBottomBorder"
           bottomBorder.frame = CGRect(
               x: 0,
               y: topView.bounds.height - borderHeight,
               width: topView.bounds.width,
               height: borderHeight
           )
           bottomBorder.backgroundColor = UIColor.systemGray5.cgColor
           topView.layer.addSublayer(bottomBorder)
       }


    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "TRSPRTpickupanddropUITableviewcell", bundle: nil), forCellReuseIdentifier: "TRSPRTpickupanddropUITableviewcell")
        tableview.register(UINib(nibName: "TRSPRpickupUITableviewcell2", bundle: nil), forCellReuseIdentifier: "TRSPRpickupUITableviewcell2")
        tableview.register(UINib(nibName: "TRSPRpickupUITableviewcell3", bundle: nil), forCellReuseIdentifier: "TRSPRpickupUITableviewcell3")
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100
    }

    private func fetchBusData() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID
        guard !studentId.isEmpty, !schoolId.isEmpty, !isLoading else { return }
        isLoading = true

        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()

        NetworkManager.shared.request(
            urlString: API.TRANSPORT_BUS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<StudentBusData>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
                switch result {
                case .success(let apiResponse):
                    if apiResponse.success, let data = apiResponse.data {
                        self.busData = data
                        if let apiRouteCode = data.route?.routeCode { self.routeCode = apiRouteCode }
                        if let apiBusNo = data.bus?.vehicleNumber { self.busNumber = apiBusNo }
                        self.tableview.reloadData()
                    }
                case .failure(let error):
                    print("❌ Error fetching bus details: \(error.localizedDescription)")
                }
            }
        }
    }

    private var studentPickupStopId: String? { busData?.pickupStop?.id }
    private var studentDropStopId: String? { busData?.dropStop?.id }

    // MARK: - Reflection Helpers for API status fields
    private func extractStringValue(from object: Any, keys: [String]) -> String? {
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            guard let label = child.label else { continue }
            if keys.contains(label) {
                if let str = child.value as? String, !str.isEmpty { return str }
                if let opt = child.value as? String?, let str = opt, !str.isEmpty { return str }
                if let num = child.value as? Int { return "\(num)" }
            }
        }
        return nil
    }
    private func extractIntValue(from object: Any, keys: [String]) -> Int? {
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            guard let label = child.label else { continue }
            if keys.contains(label) {
                if let v = child.value as? Int { return v }
                if let v = child.value as? String, let intV = Int(v) { return intV }
                if let opt = child.value as? Int?, let v = opt { return v }
            }
        }
        return nil
    }
    private func extractBoolValue(from object: Any, keys: [String]) -> Bool? {
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            guard let label = child.label else { continue }
            if keys.contains(label) {
                if let v = child.value as? Bool { return v }
                if let v = child.value as? String {
                    if v.lowercased() == "true" || v == "1" { return true }
                    if v.lowercased() == "false" || v == "0" { return false }
                }
            }
        }
        return nil
    }

    private var currentLiveStopId: String? {
        guard let data = busData else { return nil }
        return extractStringValue(from: data, keys: ["currentStopId","current_stop_id","liveStopId","live_stop_id","currentStop","activeStopId","currentLocationId","liveStop","onRouteStopId"])
    }
    private var currentLiveStopOrder: Int? {
        guard let data = busData else { return nil }
        return extractIntValue(from: data, keys: ["currentStopOrder","current_stop_order","liveStopOrder","live_stop_order","currentOrder","activeStopOrder"])
    }

    // MARK: - Core Logic: Decide Passed / Live / Upcoming
    private func findLiveStopIndex(in stops: [RouteStop], isDrop: Bool) -> Int? {
        guard !stops.isEmpty else { return nil }

        // 1. Check live ID / order from top-level busData
        if let liveId = currentLiveStopId {
            if let idx = stops.firstIndex(where: { $0.id != nil && $0.id == liveId }) {
                return idx
            }
        }
        if let liveOrder = currentLiveStopOrder {
            if let idx = stops.firstIndex(where: { $0.stopOrder != nil && $0.stopOrder == liveOrder }) {
                return idx
            }
        }

        // 2. Check explicit status string or boolean inside each RouteStop for a live indicator
        for (idx, stop) in stops.enumerated() {
            if let statusStr = extractStringValue(from: stop, keys: ["status","stopStatus","stop_status","pickupStatus","dropStatus","state","stage","currentStatus","tripStatus"])?.lowercased() {
                if statusStr.contains("live") || statusStr.contains("current") || statusStr.contains("active") || statusStr.contains("onroute") || statusStr.contains("on_route") || statusStr.contains("running") || statusStr.contains("arrived") || statusStr.contains("in_stop") || statusStr.contains("at_stop") {
                    return idx
                }
            }
            if let isLiveBool = extractBoolValue(from: stop, keys: ["isLive","is_live","live","isCurrent","is_current","current","isActive","active","isOnRoute"]), isLiveBool {
                return idx
            }
        }

        // 3. Check for transition: last stop marked "passed" -> next stop is live
        var lastPassedIdx: Int? = nil
        for (idx, stop) in stops.enumerated() {
            var isPassed = false
            if let statusStr = extractStringValue(from: stop, keys: ["status","stopStatus","stop_status","pickupStatus","dropStatus","state","stage","currentStatus","tripStatus"])?.lowercased() {
                if statusStr.contains("pass") || statusStr.contains("complete") || statusStr.contains("done") || statusStr.contains("visited") {
                    isPassed = true
                }
            }
            if !isPassed, let isPassedBool = extractBoolValue(from: stop, keys: ["isPassed","is_passed","passed","isCompleted","is_completed","completed","isVisited","visited"]) {
                if isPassedBool { isPassed = true }
            }
            if isPassed {
                lastPassedIdx = idx
            }
        }

        if let lastP = lastPassedIdx {
            if lastP + 1 < stops.count {
                return lastP + 1
            } else {
                return nil // All stops passed
            }
        }

        // 4. Fallback: Time-based active stop search
        let now = Date()
        for (idx, stop) in stops.enumerated() {
            let time: String?
            if !isDrop {
                time = stop.pickupTime
            } else {
                let drop = stop.dropTime?.trimmingCharacters(in: .whitespacesAndNewlines)
                time = (drop?.isEmpty == false) ? stop.dropTime : stop.pickupTime
            }
            let formatted = TRSPRpickupUITableviewcell2.formatTime(time, isDrop: isDrop)
            if let targetDate = timeStringToDate(raw: formatted, isDrop: isDrop) {
                let diff = targetDate.timeIntervalSince(now)
                if diff >= -600 {
                    return idx
                }
            }
        }

        return nil
    }

    private func determineStopState(stopIndex: Int, stops: [RouteStop], formattedTime: String, isDrop: Bool) -> (isPassed: Bool, isLive: Bool) {
        guard stopIndex >= 0 && stopIndex < stops.count else { return (false, false) }
        let liveIdx = findLiveStopIndex(in: stops, isDrop: isDrop)

        if let liveIdx = liveIdx {
            if stopIndex < liveIdx {
                return (true, false)
            } else if stopIndex == liveIdx {
                return (false, true)
            } else {
                return (false, false)
            }
        }

        let stop = stops[stopIndex]
        if let statusStr = extractStringValue(from: stop, keys: ["status","stopStatus","stop_status","pickupStatus","dropStatus","state","stage","currentStatus","tripStatus"])?.lowercased() {
            if statusStr.contains("pass") || statusStr.contains("complete") || statusStr.contains("done") || statusStr.contains("visited") {
                return (true, false)
            }
        }
        if let isPassedBool = extractBoolValue(from: stop, keys: ["isPassed","is_passed","passed","isCompleted","is_completed","completed","isVisited","visited"]), isPassedBool {
            return (true, false)
        }

        if let targetDate = timeStringToDate(raw: formattedTime, isDrop: isDrop) {
            if targetDate.timeIntervalSince(Date()) < -600 {
                return (true, false)
            }
        }

        return (false, false)
    }

    private func timeStringToDate(raw: String?, isDrop: Bool) -> Date? {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        if value == "--:--" { return nil }

        // Try parsing with DateFormatter for AM/PM
        let formats = ["hh:mm a","h:mm a","hh:mm:ss a","h:mm:ss a"]
        for fmt in formats {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = fmt
            if let date = df.date(from: value) {
                let cal = Calendar.current
                let comps = cal.dateComponents([.hour,.minute], from: date)
                var today = cal.dateComponents([.year,.month,.day], from: Date())
                today.hour = comps.hour
                today.minute = comps.minute
                return cal.date(from: today)
            }
        }

        // Remove fractional seconds
        if let dot = value.firstIndex(of: ".") { value = String(value[..<dot]) }

        // Manual HH:mm parsing
        let upper = value.uppercased()
        let isPM = upper.contains("PM")
        let isAM = upper.contains("AM")
        var clean = upper.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "").trimmingCharacters(in: .whitespaces)

        let parts = clean.split(separator: ":")
        guard parts.count >= 2, let h = Int(parts[0]), let m = Int(parts[1].trimmingCharacters(in: .whitespaces)) else { return nil }
        var hour = h
        let minute = m

        if isPM && hour < 12 { hour += 12 }
        if isAM && hour == 12 { hour = 0 }

        // If Drop and no AM/PM tag, assume PM for 1-11
        if !isAM && !isPM && isDrop && hour >= 1 && hour <= 11 {
            hour += 12
        }

        var today = Calendar.current.dateComponents([.year,.month,.day], from: Date())
        today.hour = hour
        today.minute = minute
        return Calendar.current.date(from: today)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TRSPRTpickupanddropVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + displayStops.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stopsCount = displayStops.count

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRSPRTpickupanddropUITableviewcell", for: indexPath) as! TRSPRTpickupanddropUITableviewcell
            cell.selectionStyle = .none
            cell.segmentcontroller.selectedSegmentIndex = selectedSegmentIndex
            cell.configureStudentName(busData?.student?.name)
            cell.configureBusNumber(busNumber)
            cell.configureRouteCode(routeCode)
            cell.configureStudentImage(urlString: UserManager.shared.resolvedStudentPhotoURL)
            cell.configureGrade()
            cell.onSegmentChange = { [weak self] index in
                self?.selectedSegmentIndex = index
                self?.tableview.reloadData()
            }
            return cell
        }

        if indexPath.row == stopsCount + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRSPRpickupUITableviewcell3", for: indexPath) as! TRSPRpickupUITableviewcell3
            cell.selectionStyle = .none
            cell.configure(driverName: busData?.driver?.name, imageURL: busData?.driver?.profileImage)
            cell.onCallTapped = { [weak self] in
                guard let phone = self?.busData?.driver?.mobile, !phone.isEmpty else { return }
                if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
            }
            cell.onMessageTapped = { [weak self] in
                guard let phone = self?.busData?.driver?.mobile, !phone.isEmpty else { return }
                if let url = URL(string: "sms://\(phone)"), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
            }
            return cell
        }

        let stopIndex = indexPath.row - 1
        let stop = displayStops[stopIndex]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRSPRpickupUITableviewcell2", for: indexPath) as! TRSPRpickupUITableviewcell2
        cell.selectionStyle = .none

        let isDrop = (selectedSegmentIndex == 1)
        let time: String?
        if !isDrop {
            time = stop.pickupTime
        } else {
            let drop = stop.dropTime?.trimmingCharacters(in: .whitespacesAndNewlines)
            time = (drop?.isEmpty == false) ? stop.dropTime : stop.pickupTime
        }

        let isYourStop: Bool
        if !isDrop {
            isYourStop = (stop.id != nil && stop.id == studentPickupStopId)
        } else {
            isYourStop = (stop.id != nil && stop.id == studentDropStopId)
        }

        let formatted = TRSPRpickupUITableviewcell2.formatTime(time, isDrop: isDrop)
        let state = determineStopState(stopIndex: stopIndex, stops: displayStops, formattedTime: formatted, isDrop: isDrop)

        cell.configure(
            stopName: stop.stopName,
            time: time,
            isYourStop: isYourStop,
            isFirst: stopIndex == 0,
            isLast: stopIndex == stopsCount - 1,
            stopOrder: stop.stopOrder,
            isDrop: isDrop,
            isPassed: state.isPassed,
            isLive: state.isLive
        )
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let stopsCount = displayStops.count
        if indexPath.row == 0 { return 280 }
        else if indexPath.row == stopsCount + 1 { return 200 }
        else { return 90}
    }
}
