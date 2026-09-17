//
//  TranportParentDashbordVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/07/26.
//

import UIKit

class TranportParentDashbordVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!

    // MARK: - Outlets
    @IBOutlet weak var Tableview: UITableView!

    // MARK: - API Data
    private var busData: StudentBusData?
    private var routeData: TransportRouteData?
    private var isLoading = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchBusDetails()   // ✅ Load bus details
        fetchRouteDetails() // ✅ Load Route Pickup & Drop details
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup
    private func setupTableView() {
        Tableview.delegate   = self
        Tableview.dataSource = self

        Tableview.register(
            UINib(nibName: "TRNSPTdashbordUITableViewCell1", bundle: nil),
            forCellReuseIdentifier: "TRNSPTdashbordUITableViewCell1"
        )

        Tableview.separatorStyle               = .none
        Tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - Fetch Bus Details API
    private func fetchBusDetails() {

        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {
            print("❌ Student ID is empty")
            return
        }

        guard !schoolId.isEmpty else {
            print("❌ School ID is empty")
            return
        }

        guard !isLoading else { return }
        isLoading = true

        showLoader()

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
                self.hideLoader()

                switch result {

                case .success(let response):

                    if response.success, let data = response.data {

                        self.busData = data

                        print("✅ Bus details retrieved successfully")
                        print("🚌 Vehicle Number: \(data.bus?.vehicleNumber ?? "N/A")")
                        print("👨‍✈️ Driver: \(data.driver?.name ?? "N/A")")
                        print("🧑‍💼 Attendant: \(data.attendant?.name ?? "N/A")")

                        self.Tableview.reloadData()

                    } else {
                        print("❌ Bus API returned no data: \(response.description)")
                    }

                case .failure(let error):

                    switch error {
                    case .noaccess:
                        print("❌ Session expired")
                    default:
                        print("❌ Bus API error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Fetch Transport Route Details API
    private func fetchRouteDetails() {

        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {
            print("❌ Student ID is empty")
            return
        }

        guard !schoolId.isEmpty else {
            print("❌ School ID is empty")
            return
        }

        NetworkManager.shared.request(
            urlString: API.TRANSPORT_ROUTEDETAILS,
            method: .GET,
            requiresAuth: true,
            parameters: [
                "student_id": studentId
            ],
            headers: [
                "X-School-Id": schoolId
            ]
        ) { [weak self] (result: Result<APIResponse<TransportRouteData>, NetworkError>) in

            guard let self = self else { return }

            DispatchQueue.main.async {

                switch result {

                case .success(let response):

                    if response.success, let data = response.data {

                        self.routeData = data

                        print("✅ Route details retrieved successfully")
                        print("🗺️ Route Name: \(data.route?.routeName ?? "N/A")")
                        print("📍 Pickup Stop: \(data.pickupStop?.stopName ?? "N/A") - \(data.pickupStop?.pickupTime ?? "N/A")")
                        print("📍 Drop Stop: \(data.dropStop?.stopName ?? "N/A") - \(data.dropStop?.dropTime ?? "N/A")")

                        self.Tableview.reloadData()

                    } else {
                        print("❌ Route API returned no data: \(response.description)")
                    }

                case .failure(let error):

                    switch error {
                    case .noaccess:
                        print("❌ Session expired")
                    default:
                        print("❌ Route API error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Navigation Helpers
    private func navigateToLiveTracking() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "BuslivetrackingVC"
        ) as? BuslivetrackingVC else {
            print("❌ BuslivetrackingVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToPickupandDrop() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "TRSPRTpickupanddropVC"
        ) as? TRSPRTpickupanddropVC else {
            print("❌ TRSPRTpickupanddropVC not found in storyboard. Check Storyboard ID.")
            return
        }
        // Pass Bus Number and Route Code from Dashboard API Data
        vc.busNumber = busData?.bus?.vehicleNumber
        vc.routeCode = routeData?.route?.routeCode
        
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToFeeModule() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "TRSPRTfeepaymentVC"
        ) as? TRSPRTfeepaymentVC else {
            print("❌ TRSPRTfeepaymentVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToDriverContact() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "TRSPRTcantactdriverVC"
        ) as? TRSPRTcantactdriverVC else {
            print("❌ TRSPRTcantactdriverVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TranportParentDashbordVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRNSPTdashbordUITableViewCell1",
            for: indexPath
        ) as! TRNSPTdashbordUITableViewCell1

        cell.selectionStyle = .none

        // Assign delegate so cell can trigger navigation
        cell.delegate = self

        // ✅ Configure cell with bus data and route data
        cell.configureBusDetails(busData)
        cell.configureRouteDetails(routeData)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 900
    }
}

// MARK: - TRNSPTdashbordCell1Delegate
extension TranportParentDashbordVC: TRNSPTdashbordCell1Delegate {

    func didTapLiveTracking() {
        navigateToLiveTracking()
    }

    func didTapDriverContact() {
        navigateToDriverContact()
    }
    func didTapFeeModule() {
        navigateToFeeModule()
    }
    func didTapPickupandDrop() {
        navigateToPickupandDrop()
    }
}
