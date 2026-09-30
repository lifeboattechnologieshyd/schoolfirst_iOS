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

    /// ✅ API only once per screen entry
    private var hasFetchedOnce = false

    /// Morning  → ascending (home → school)
    /// Evening  → reversed  (school → home)  ← matches Figma
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
        setupTopViewBottomShadowAndBorder()
        setupFonts()
        // ✅ Call API only once when entering screen
        fetchBusDataIfNeeded()
    }

    private func setupFonts() {
        PickupanddropLabel?.font = .hankenSemiBold(size: 20)
    }

    private func setupTopViewBottomShadowAndBorder() {
        guard let topView = Topview else { return }
        topView.layer.masksToBounds = false
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOpacity = 0.08
        topView.layer.shadowOffset = CGSize(width: 0, height: 3)
        topView.layer.shadowRadius = 4.0

        let shadowRect = CGRect(x: 0, y: topView.bounds.height - 2, width: topView.bounds.width, height: 4)
        topView.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath

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

    // MARK: - ✅ Fetch ONLY once when entering screen
    private func fetchBusDataIfNeeded() {
        // Already fetched OR currently loading → do nothing
        guard !hasFetchedOnce, !isLoading else { return }
        fetchBusData()
    }

    private func fetchBusData() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID
        guard !studentId.isEmpty, !schoolId.isEmpty, !isLoading else { return }

        // ✅ Lock so it never fires again for this screen session
        isLoading = true
        hasFetchedOnce = true

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
                    } else {
                        // Allow retry only if response failed with no data
                        self.hasFetchedOnce = false
                    }
                case .failure(let error):
                    // Allow retry on failure (user can pull / re-enter)
                    self.hasFetchedOnce = false
                    print("❌ Error fetching bus details: \(error.localizedDescription)")
                }
            }
        }
    }

    private var studentPickupStopId: String? { busData?.pickupStop?.id }
    private var studentDropStopId: String? { busData?.dropStop?.id }

    // MARK: - Stop State (ALWAYS top → bottom in display order)
    /// - trip_status == COMPLETED → all PASSED
    /// - index < first PENDING  → PASSED
    /// - index == first PENDING → LIVE (only if bus already started)
    /// - index > first PENDING  → Upcoming
    private func determineStopState(stopIndex: Int, stops: [RouteStop]) -> (isPassed: Bool, isLive: Bool) {
        guard stopIndex >= 0 && stopIndex < stops.count else { return (false, false) }

        let tripStatus = (busData?.tripStatus ?? "").uppercased()

        // Entire trip finished → every stop is PASSED
        if tripStatus == "COMPLETED" {
            return (true, false)
        }

        // First PENDING stop in the *currently displayed* list (top → bottom)
        let firstPendingIdx = stops.firstIndex {
            ($0.status ?? "").uppercased() == "PENDING"
        }

        if let liveIdx = firstPendingIdx {
            if stopIndex < liveIdx {
                return (true, false)
            } else if stopIndex == liveIdx {
                let hasAnyReached = stops.contains {
                    ($0.status ?? "").uppercased() == "REACHED"
                }
                if hasAnyReached {
                    return (false, true)
                }
                return (false, false)
            } else {
                return (false, false)
            }
        }

        // No PENDING left → all REACHED → PASSED
        let currentStatus = (stops[stopIndex].status ?? "").uppercased()
        if currentStatus == "REACHED" {
            return (true, false)
        }

        return (false, false)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TRSPRTpickupanddropVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + displayStops.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stopsCount = displayStops.count

        // MARK: Header cell
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TRSPRTpickupanddropUITableviewcell",
                for: indexPath
            ) as! TRSPRTpickupanddropUITableviewcell
            cell.selectionStyle = .none
            cell.segmentcontroller.selectedSegmentIndex = selectedSegmentIndex
            cell.configureStudentName(busData?.student?.name)
            cell.configureBusNumber(busNumber)
            cell.configureRouteCode(routeCode)
            cell.configureStudentImage(urlString: UserManager.shared.resolvedStudentPhotoURL)
            cell.configureGrade()
            cell.onSegmentChange = { [weak self] index in
                // ✅ Segment change → local reload ONLY (NO API call)
                self?.selectedSegmentIndex = index
                self?.tableview.reloadData()
            }
            return cell
        }

        // MARK: Driver cell
        if indexPath.row == stopsCount + 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TRSPRpickupUITableviewcell3",
                for: indexPath
            ) as! TRSPRpickupUITableviewcell3
            cell.selectionStyle = .none
            cell.configure(
                driverName: busData?.driver?.name,
                imageURL: busData?.driver?.profileImage
            )
            cell.onCallTapped = { [weak self] in
                guard let phone = self?.busData?.driver?.mobile, !phone.isEmpty else { return }
                if let url = URL(string: "tel://\(phone)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            cell.onMessageTapped = { [weak self] in
                guard let phone = self?.busData?.driver?.mobile, !phone.isEmpty else { return }
                if let url = URL(string: "sms://\(phone)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            return cell
        }

        // MARK: Stop cell
        let stopIndex = indexPath.row - 1
        let stop = displayStops[stopIndex]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRSPRpickupUITableviewcell2",
            for: indexPath
        ) as! TRSPRpickupUITableviewcell2
        cell.selectionStyle = .none

        let isDrop = (selectedSegmentIndex == 1)
        let isSchool = (stop.stopType ?? "").uppercased() == "SCHOOL"

        // Time selection
        let time: String?
        if isSchool {
            if isDrop {
                time = stop.pickupTime ?? stop.dropTime
            } else {
                time = stop.dropTime ?? stop.pickupTime
            }
        } else if !isDrop {
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

        let state = determineStopState(stopIndex: stopIndex, stops: displayStops)

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
        else { return 90 }
    }
}
