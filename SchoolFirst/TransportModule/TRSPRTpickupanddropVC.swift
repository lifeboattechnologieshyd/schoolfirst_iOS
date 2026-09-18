//
//  TRSPRTpickupanddropVC.swift
//  SchoolFirst
//

import UIKit

class TRSPRTpickupanddropVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    // 0 = Morning Pickup, 1 = Evening Drop
    private var selectedSegmentIndex: Int = 0

    // Passed from dashboard (optional fallback)
    var busNumber: String?
    var routeCode: String?

    // API Response
    private var busData: StudentBusData?
    private var isLoading = false

    // Sorted route stops used for the list (depends on segment)
    private var displayStops: [RouteStop] {
        let stops = busData?.routeStops ?? []
        let ascending = stops.sorted { ($0.stopOrder ?? 0) < ($1.stopOrder ?? 0) }

        // Pickup → top to bottom (source → school)
        // Drop   → top to bottom reverse (school → home)
        if selectedSegmentIndex == 1 {
            return ascending.reversed()
        }
        return ascending
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchBusData()
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "TRSPRTpickupanddropUITableviewcell", bundle: nil),
            forCellReuseIdentifier: "TRSPRTpickupanddropUITableviewcell"
        )
        tableview.register(
            UINib(nibName: "TRSPRpickupUITableviewcell2", bundle: nil),
            forCellReuseIdentifier: "TRSPRpickupUITableviewcell2"
        )
        tableview.register(
            UINib(nibName: "TRSPRpickupUITableviewcell3", bundle: nil),
            forCellReuseIdentifier: "TRSPRpickupUITableviewcell3"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100
    }

    // MARK: - Fetch Bus Data
    private func fetchBusData() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {
            print("❌ Student ID is empty in TRSPRTpickupanddropVC")
            return
        }
        guard !schoolId.isEmpty else {
            print("❌ School ID is empty in TRSPRTpickupanddropVC")
            return
        }
        guard !isLoading else { return }
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
            parameters: [
                "student_id": studentId
            ],
            headers: [
                "X-School-Id": schoolId
            ]
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

                        if let apiRouteCode = data.route?.routeCode {
                            self.routeCode = apiRouteCode
                        }
                        if let apiBusNo = data.bus?.vehicleNumber {
                            self.busNumber = apiBusNo
                        }

                        print("✅ Bus details retrieved. Stops count: \(data.routeStops?.count ?? 0)")
                        self.tableview.reloadData()
                    } else {
                        print("❌ Bus API returned no data: \(apiResponse.description)")
                    }

                case .failure(let error):
                    print("❌ Error fetching bus details: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Helpers for stop identity
    private var studentPickupStopId: String? {
        busData?.pickupStop?.id
    }

    private var studentDropStopId: String? {
        busData?.dropStop?.id
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TRSPRTpickupanddropVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1 Header + N Stops + 1 Driver
        return 1 + displayStops.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let stopsCount = displayStops.count

        // ─────────────────────────────────────────
        // ROW 0 → Header (Student / Route / Segment)
        // ─────────────────────────────────────────
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

            // ✅ Student profile image (saved from login/profile via UserManager)
            cell.configureStudentImage(urlString: UserManager.shared.resolvedStudentPhotoURL)

            // ✅ Grade from UserDefaults ("Grade 5 - A") via UserManager
            cell.configureGrade()

            cell.onSegmentChange = { [weak self] index in
                guard let self = self else { return }
                self.selectedSegmentIndex = index
                self.tableview.reloadData()
            }

            return cell
        }

        // ─────────────────────────────────────────
        // LAST ROW → Driver Card
        // ─────────────────────────────────────────
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
                if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }

            cell.onMessageTapped = { [weak self] in
                guard let phone = self?.busData?.driver?.mobile, !phone.isEmpty else { return }
                if let url = URL(string: "sms://\(phone)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }

            return cell
        }

        // ─────────────────────────────────────────
        // MIDDLE ROWS → All Route Stops
        // ─────────────────────────────────────────
        let stopIndex = indexPath.row - 1
        let stop = displayStops[stopIndex]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRSPRpickupUITableviewcell2",
            for: indexPath
        ) as! TRSPRpickupUITableviewcell2

        cell.selectionStyle = .none

        let isDrop = (selectedSegmentIndex == 1)

        // Time depends on segment
        let time: String?
        if !isDrop {
            // Morning Pickup
            time = stop.pickupTime
        } else {
            // Evening Drop
            let drop = stop.dropTime?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let drop = drop, !drop.isEmpty {
                time = stop.dropTime
            } else {
                time = stop.pickupTime
            }
        }

        // Identify student's own stop
        let isYourStop: Bool
        if !isDrop {
            isYourStop = (stop.id != nil && stop.id == studentPickupStopId)
        } else {
            isYourStop = (stop.id != nil && stop.id == studentDropStopId)
        }

        let isFirst = (stopIndex == 0)
        let isLast  = (stopIndex == stopsCount - 1)

        cell.configure(
            stopName: stop.stopName,
            time: time,
            isYourStop: isYourStop,
            isFirst: isFirst,
            isLast: isLast,
            stopOrder: stop.stopOrder,
            isDrop: isDrop
        )

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let stopsCount = displayStops.count

        if indexPath.row == 0 {
            return 280         // Header
        } else if indexPath.row == stopsCount + 1 {
            return 200          // Driver
        } else {
            return 100          // Each stop cell
        }
    }
}
