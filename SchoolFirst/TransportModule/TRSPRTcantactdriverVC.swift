//
//  TRSPRTcantactdriverVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPRTcantactdriverVC: UIViewController {

    @IBOutlet weak var ContactdriverLabel: UILabel!
    @IBOutlet weak var Topview: UIView!
    // MARK: - Outlets
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Properties
    private var busDetails: StudentBusData?
    private var isLoading = false
    
    // Native Loading Indicator
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewBottomShadowAndBorder()
        setupLoader()
        setupTableView()
        fetchBusDetails()
    }
    private func setupFonts() {
        ContactdriverLabel?.font = .hankenBold(size: 20)
        
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

    // MARK: - Back Button Action
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup Loading View Constraints
    private func setupLoader() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(
                nibName: "TRSPRTcantactdriverVCUITableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "TRSPRTcantactdriverVCUITableViewCell"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - Fetch API Data
    private func fetchBusDetails() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {
            print("❌ Student ID is empty")
            self.showErrorAlert(message: "Student configuration is missing.")
            return
        }

        guard !schoolId.isEmpty else {
            print("❌ School ID is empty")
            self.showErrorAlert(message: "School configuration is missing.")
            return
        }

        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()

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
                self.activityIndicator.stopAnimating()

                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.busDetails = data

                        print("✅ Driver object received:")
                        print("   name     :", data.driver?.name ?? "nil")
                        print("   mobile   :", data.driver?.mobile ?? "nil")
                        print("   image    :", data.driver?.profileImage ?? "nil")
                        print("   exp      :", data.driver?.experience ?? -1)

                        self.tableview.reloadData()
                    } else {
                        let errorMsg = response.description.isEmpty ? "No driver details available." : response.description
                        self.showErrorAlert(message: errorMsg)
                    }

                case .failure(let error):
                    switch error {
                    case .noaccess:
                        print("❌ Session expired")
                    case .noInternet:
                        print("❌ No internet")
                    case .serverError(let message):
                        self.showErrorAlert(message: message)
                    case .decodingError(let message):
                        print("❌ Decoding Error: \(message)")
                        self.showErrorAlert(message: "Failed to parse data from the server.")
                    case .invalidURL:
                        self.showErrorAlert(message: "Invalid Request URL.")
                    case .noData:
                        self.showErrorAlert(message: "No data received from server.")
                    }
                }
            }
        }
    }

    // MARK: - ✅ Call Driver (tel://) using API mobile number
    private func callDriver() {
        guard let phone = busDetails?.driver?.mobile?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !phone.isEmpty else {
            print("❌ Driver mobile number not available")
            let alert = UIAlertController(
                title: "Driver Contact",
                message: "Driver phone number is not available.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Clean number: remove spaces, dashes, brackets
        let cleanNumber = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        guard let url = URL(string: "tel://\(cleanNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            print("❌ Cannot place call to: \(cleanNumber)")
            return
        }

        print("📞 Calling driver: \(cleanNumber)")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // MARK: - Error Handling Alert Helper
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Driver Details",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.fetchBusDetails()
        }))
        self.present(alert, animated: true)
    }

    // MARK: - Navigation Helper (Passes Driver Name, Status, Image, Mobile to Chat VC)
    private func navigateToChat() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "comimgsoonVC"
        ) as? comimgsoonVC else {
            print("❌ TRSPTchatVC not found in storyboard. Check Storyboard ID.")
            return
        }
        
        // ✅ Pass all required data to ChatVC
        chatVC.driverName      = busDetails?.driver?.name ?? "Driver"
        chatVC.driverStatus    = busDetails?.bus?.status ?? "Active"
        chatVC.driverImageURL  = busDetails?.driver?.profileImage
        chatVC.driverMobile    = busDetails?.driver?.mobile
        
        navigationController?.pushViewController(chatVC, animated: true)
    }

    // MARK: - Navigate to Live Tracking
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
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension TRSPRTcantactdriverVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRSPRTcantactdriverVCUITableViewCell",
            for: indexPath
        ) as? TRSPRTcantactdriverVCUITableViewCell else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.configure(with: busDetails)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 750
    }
}

// MARK: - TRSPRTcantactdriverCellDelegate
extension TRSPRTcantactdriverVC: TRSPRTcantactdriverCellDelegate {

    func didTapMessageButton() {
        navigateToChat()
    }

    func didTapLiveTrackButton() {
        navigateToLiveTracking()
    }

    func didTapVoiceCallButton() {
        callDriver()
    }
}
