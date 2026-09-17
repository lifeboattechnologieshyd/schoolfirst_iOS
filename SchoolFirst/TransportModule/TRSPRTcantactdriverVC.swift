//
//  TRSPRTcantactdriverVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPRTcantactdriverVC: UIViewController {

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
        setupLoader()
        setupTableView()
        fetchBusDetails()
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

    // MARK: - Navigation Helper (Passes Driver Name & Status to Chat VC)
    private func navigateToChat() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "TRSPTchatVC"
        ) as? TRSPTchatVC else {
            print("❌ TRSPTchatVC not found in storyboard. Check Storyboard ID.")
            return
        }
        
        // Pass the driver name and status to ChatVC
        chatVC.driverName = busDetails?.driver?.name ?? "Driver"
        chatVC.driverStatus = busDetails?.bus?.status ?? "Active"
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension TRSPRTcantactdriverVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busDetails != nil ? 1 : 0
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
        return 800
    }
}

// MARK: - TRSPRTcantactdriverCellDelegate
extension TRSPRTcantactdriverVC: TRSPRTcantactdriverCellDelegate {

    func didTapMessageButton() {
        navigateToChat()
    }
}
