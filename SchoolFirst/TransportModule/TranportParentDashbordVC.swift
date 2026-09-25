//
//  TranportParentDashbordVC.swift
//  SchoolFirst
//

import UIKit

class TranportParentDashbordVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    @IBOutlet weak var GoodmornigparentLabel: UILabel!
    var busData: StudentBusData?
    var isLoading = false

    func setInitialBusData(_ data: StudentBusData) {
        self.busData = data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚍 TranportParentDashbordVC - viewDidLoad")
        setupTableView()
        setupFonts()

        guard let data = busData,
              let bus = data.bus,
              !(bus.vehicleNumber ?? "").isEmpty else {
            print("⚠️ No valid bus data found. ➡️ Redirecting to TransportnotoptedVC")
            redirectToNotOptedVC()
            return
        }

        print("✅ Valid bus data found 🚌 \(bus.vehicleNumber ?? "N/A")")
        Tableview.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

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
    

    private func fetchBusDetails() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID
        guard !studentId.isEmpty else { print("❌ Student ID is empty"); redirectToNotOptedVC(); return }
        guard !schoolId.isEmpty else { print("❌ School ID is empty"); redirectToNotOptedVC(); return }
        guard !isLoading else { return }
        isLoading = true
        showLoader()

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
                        print("✅ Bus details retrieved 🚌 \(bus.vehicleNumber ?? "N/A")")
                        self.Tableview.reloadData()
                    } else {
                        print("❌ No bus data: \(response.description ?? "") ➡️ NotOpted")
                        self.redirectToNotOptedVC()
                    }
                case .failure(let error):
                    print("❌ Bus API error: \(error.localizedDescription) ➡️ NotOpted")
                    self.redirectToNotOptedVC()
                }
            }
        }
    }

    // ✅ THE FIX: dismiss any blocking "Error" alert first, then replace/push.
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
                    print("✅ Replaced dashboard with TransportnotoptedVC")
                } else {
                    nav.pushViewController(vc, animated: true)
                    print("✅ Pushed TransportnotoptedVC")
                }
            }

            let blocker = self.presentedViewController
                ?? self.navigationController?.presentedViewController
            if let blocker = blocker {
                print("⚠️ Dismissing blocking alert: \(type(of: blocker))")
                blocker.dismiss(animated: false, completion: doReplace)
            } else {
                doReplace()
            }
        }
    }

    // MARK: - Call Helpers
    private func callPhoneNumber(_ phone: String?, contactTitle: String) {
        guard let phone = phone?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty else {
            let alert = UIAlertController(title: "\(contactTitle) Contact", message: "\(contactTitle) phone number is not available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let cleanNumber = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        guard let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) else { return }
        print("📞 Calling \(contactTitle): \(cleanNumber)")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func callDriver() { callPhoneNumber(busData?.driver?.mobile, contactTitle: "Driver") }
    private func callAttendant() { callPhoneNumber(busData?.attendant?.mobile, contactTitle: "Attendant") }

    private func navigateToLiveTracking() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BuslivetrackingVC") as? BuslivetrackingVC else { return }
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

extension TranportParentDashbordVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRNSPTdashbordUITableViewCell1", for: indexPath) as! TRNSPTdashbordUITableViewCell1
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configureBusDetails(busData)
        cell.configureRouteDetails(busData)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 900 }
}

extension TranportParentDashbordVC: TRNSPTdashbordCell1Delegate {
    func didTapLiveTracking() { navigateToLiveTracking() }
    func didTapDriverContact() { navigateToDriverContact() }
    func didTapFeeModule() { navigateToFeeModule() }
    func didTapPickupandDrop() { navigateToPickupandDrop() }
    func didTapCallDriver() { callDriver() }
    func didTapCallAttendant() { callAttendant() }
}
