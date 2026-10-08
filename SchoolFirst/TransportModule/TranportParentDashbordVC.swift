//
//  TranportParentDashbordVC.swift
//  SchoolFirst
//

import UIKit
import MapKit // ✅ MapKit required for Live ETA Calculation

class TranportParentDashbordVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var GoodmornigparentLabel: UILabel!
    
    var busData: StudentBusData?
    var isLoading = false
    
    // ✅ Live Location & ETA
    private var liveETASeconds: TimeInterval?
    private var liveLocationTimer: Timer?
    private var isFetchingLiveLocation = false
    private var isCalculatingETA = false
    private let liveLocationInterval: TimeInterval = 20.0  // every 20 seconds

    func setInitialBusData(_ data: StudentBusData) {
        self.busData = data
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚍 TranportParentDashbordVC - viewDidLoad")
        setupTableView()
        setupFonts()

        if let data = busData, let bus = data.bus, !(bus.vehicleNumber ?? "").isEmpty {
            print("✅ Initial bus data found 🚌 \(bus.vehicleNumber ?? "N/A")")
            Tableview.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        fetchBusDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLiveLocationTimer()
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.register(
            UINib(nibName: "TRNSPTdashbordUITableViewCell1", bundle: nil),
            forCellReuseIdentifier: "TRNSPTdashbordUITableViewCell1"
        )
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
    }
    
    private func setupFonts() {
        GoodmornigparentLabel?.font = .hankenBold(size: 20)
    }

    // MARK: - Bus Details API
    private func fetchBusDetails() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID
        guard !studentId.isEmpty else { print("❌ Student ID is empty"); redirectToNotOptedVC(); return }
        guard !schoolId.isEmpty else { print("❌ School ID is empty"); redirectToNotOptedVC(); return }
        guard !isLoading else { return }
        
        isLoading = true
        if busData == nil { showLoader() }

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
                self.hideLoader()
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data, let bus = data.bus, !(bus.vehicleNumber ?? "").isEmpty {
                        self.busData = data
                        print("✅ Bus details updated 🚌 \(bus.vehicleNumber ?? "N/A")")
                        self.Tableview.reloadData()
                        
                        // ✅ After data load → check & start live tracking if needed
                        self.manageLiveLocationTimer()
                    } else {
                        print("❌ No bus data ➡️ NotOpted")
                        if self.busData == nil { self.redirectToNotOptedVC() }
                    }
                case .failure(let error):
                    print("❌ Bus API error: \(error.localizedDescription)")
                    if self.busData == nil { self.redirectToNotOptedVC() }
                }
            }
        }
    }

    // MARK: - Live Location Timer Management
    private func manageLiveLocationTimer() {
        guard let data = busData else {
            stopLiveLocationTimer()
            return
        }
        
        let rawStatus = (data.tripStatus ?? "").lowercased()
        let isActive = ["active", "started", "live", "running", "on_route"].contains(rawStatus)
        
        // Student's target stop
        let shift = (data.tripShift ?? data.route?.shift ?? "MORNING").uppercased()
        let isEvening = shift == "EVENING" || shift == "AFTERNOON" || (data.tripType ?? "").uppercased() == "DROP"
        let targetStopId = isEvening ? data.dropStop?.id : data.pickupStop?.id
        
        let studentRouteStop = data.routeStops?.first(where: { $0.id == targetStopId })
        let stopStatus = (studentRouteStop?.status ?? "").lowercased()
        let hasReachedTime = !(studentRouteStop?.reachedTime ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isStopReached = stopStatus.contains("reach") || stopStatus.contains("complete") || hasReachedTime
        
        // Only poll when bus active AND student stop not yet reached
        if isActive && !isStopReached {
            if liveLocationTimer == nil {
                print("🟢 Starting live location timer (every \(liveLocationInterval)s)")
                fetchLiveLocation()  // Immediate first call
                liveLocationTimer = Timer.scheduledTimer(
                    timeInterval: liveLocationInterval,
                    target: self,
                    selector: #selector(fetchLiveLocation),
                    userInfo: nil,
                    repeats: true
                )
            }
        } else {
            print("🛑 Stop reached or trip inactive. Stopping live timer.")
            stopLiveLocationTimer()
            liveETASeconds = nil
        }
    }
    
    private func stopLiveLocationTimer() {
        liveLocationTimer?.invalidate()
        liveLocationTimer = nil
    }

    // MARK: - Live Location API
    @objc private func fetchLiveLocation() {
        guard !isFetchingLiveLocation else { return }
        guard let vehicleId = busData?.bus?.id, !vehicleId.isEmpty else {
            print("⚠️ Missing vehicle id for live location")
            return
        }
        
        let schoolId = UserManager.shared.resolvedSchoolID
        isFetchingLiveLocation = true
        
        var parameters: [String: Any] = ["vehicle_id": vehicleId]
        if let tripId = busData?.tripId, !tripId.isEmpty {
            parameters["trip_id"] = tripId
        }

        NetworkManager.shared.request(
            urlString: API.TRANSPORT_LIVELOCATION,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<TransportLiveLocationData>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetchingLiveLocation = false
                
                switch result {
                case .success(let response):
                    guard let location = response.data?.location,
                          let lat = location.latitude,
                          let lng = location.longitude,
                          lat != 0, lng != 0 else {
                        print("⚠️ Live location unavailable")
                        return
                    }
                    print("📍 Bus Live Location: \(lat), \(lng)")
                    self.calculateLiveETAWithAppleMaps(busLat: lat, busLng: lng)
                    
                case .failure(let error):
                    print("❌ Live location error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - MapKit ETA Calculation
    private func calculateLiveETAWithAppleMaps(busLat: Double, busLng: Double) {
        guard !isCalculatingETA else { return }
        guard let data = busData else { return }
        
        let shift = (data.tripShift ?? data.route?.shift ?? "MORNING").uppercased()
        let isEvening = shift == "EVENING" || shift == "AFTERNOON" || (data.tripType ?? "").uppercased() == "DROP"
        let targetStop = isEvening ? data.dropStop : data.pickupStop
        
        guard let stopLat = targetStop?.latitude,
              let stopLng = targetStop?.longitude,
              stopLat != 0, stopLng != 0 else {
            print("⚠️ Student stop coordinates missing")
            return
        }
        
        isCalculatingETA = true
        
        let sourceCoord = CLLocationCoordinate2D(latitude: busLat, longitude: busLng)
        let destCoord = CLLocationCoordinate2D(latitude: stopLat, longitude: stopLng)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoord))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoord))
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculateETA { [weak self] response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isCalculatingETA = false
                
                if let error = error {
                    print("❌ ETA error: \(error.localizedDescription)")
                    return
                }
                guard let eta = response?.expectedTravelTime, eta > 0 else { return }
                
                self.liveETASeconds = eta
                let mins = Int(eta / 60)
                print("🕐 Live ETA from MapKit: \(mins) min")
                
                // ✅ Flicker-free update: directly update the visible cell
                self.updateVisibleCellETA()
            }
        }
    }
    
    private func updateVisibleCellETA() {
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = Tableview.cellForRow(at: indexPath) as? TRNSPTdashbordUITableViewCell1 {
            cell.configureRouteDetails(busData, liveETASeconds: liveETASeconds)
        }
    }

    // MARK: - Not Opted Redirect
    private func redirectToNotOptedVC() {
        print("🚫 redirectToNotOptedVC() called")

        if let nav = navigationController, nav.topViewController is TransportnotoptedVC {
            print("⚠️ TransportnotoptedVC already visible")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: TransportnotoptedVC
        if let sbVC = storyboard.instantiateViewController(withIdentifier: "TransportnotoptedVC") as? TransportnotoptedVC {
            vc = sbVC
        } else {
            vc = TransportnotoptedVC()
        }
        vc.hidesBottomBarWhenPushed = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }

            let doReplace = { [weak self] in
                guard let self = self else { return }
                guard let nav = self.navigationController else {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                    return
                }
                var viewControllers = nav.viewControllers
                if let currentIndex = viewControllers.firstIndex(where: { $0 === self }) {
                    viewControllers[currentIndex] = vc
                    nav.setViewControllers(viewControllers, animated: true)
                } else {
                    nav.pushViewController(vc, animated: true)
                }
            }

            let blocker = self.presentedViewController
                ?? self.navigationController?.presentedViewController
            if let blocker = blocker {
                blocker.dismiss(animated: false, completion: doReplace)
            } else {
                doReplace()
            }
        }
    }

    // MARK: - Call Helpers
    private func callPhoneNumber(_ phone: String?, contactTitle: String) {
        guard let phone = phone?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty else {
            let alert = UIAlertController(
                title: "\(contactTitle) Contact",
                message: "\(contactTitle) phone number is not available.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let cleanNumber = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        guard let url = URL(string: "tel://\(cleanNumber)"),
              UIApplication.shared.canOpenURL(url) else { return }
        print("📞 Calling \(contactTitle): \(cleanNumber)")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func callDriver() { callPhoneNumber(busData?.driver?.mobile, contactTitle: "Driver") }
    private func callAttendant() { callPhoneNumber(busData?.attendant?.mobile, contactTitle: "Attendant") }

    // MARK: - Navigation
    private func navigateToLiveTracking() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BuslivetrackingVC") as? BuslivetrackingVC else { return }
        vc.busData = busData
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToPickupandDrop() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "TRSPRTpickupanddropVC") as? TRSPRTpickupanddropVC else { return }
        vc.busNumber = busData?.bus?.vehicleNumber
        vc.routeCode = busData?.route?.routeCode
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToFeeModule() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "TRSPRTfeepaymentVC") as? TRSPRTfeepaymentVC else { return }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToDriverContact() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "TRSPRTcantactdriverVC") as? TRSPRTcantactdriverVC else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView
extension TranportParentDashbordVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRNSPTdashbordUITableViewCell1",
            for: indexPath
        ) as! TRNSPTdashbordUITableViewCell1
        
        cell.selectionStyle = .none
        cell.delegate = self
        
        cell.configureBusDetails(busData)
        cell.configureRouteDetails(busData, liveETASeconds: liveETASeconds) // ✅ pass Live ETA
        cell.configureTripStatus(busData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 940 }
}

// MARK: - Cell Delegate
extension TranportParentDashbordVC: TRNSPTdashbordCell1Delegate {
    func didTapLiveTracking() { navigateToLiveTracking() }
    func didTapDriverContact() { navigateToDriverContact() }
    func didTapFeeModule() { navigateToFeeModule() }
    func didTapPickupandDrop() { navigateToPickupandDrop() }
    func didTapCallDriver() { callDriver() }
    func didTapCallAttendant() { callAttendant() }
}
