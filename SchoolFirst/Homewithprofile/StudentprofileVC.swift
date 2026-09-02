//
//  StudentprofileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/05/26.
//

import UIKit

class StudentprofileVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    
    // Top View / Staff
    @IBOutlet weak var topVw: UIView!

    // MARK: - Properties

    let cellIdentifier = "StudentdetailsTableViewCell"
    let documentCellIdentifier = "DocumentsTableViewCell2"
    
    private var profileData: StudentProfileData?
    private var loadedStudentId: String = ""

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNotificationButton()
        setupBackButton()
        setupTopView()
        
        fetchStudentProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: animated
        )
        
        // Dynamic reload on Student Switch
        let currentStudentId = UserManager.shared.resolvedStudentID
        if currentStudentId != loadedStudentId && !currentStudentId.isEmpty {
            print("🔄 Student changed to: \(currentStudentId). Fetching new profile...")
            fetchStudentProfile()
        }
    }

    // MARK: - TableView Setup

    private func setupTableView() {
        TableView.delegate = self
        TableView.dataSource = self

        TableView.register(
            UINib(nibName: cellIdentifier, bundle: nil),
            forCellReuseIdentifier: cellIdentifier
        )
        
        TableView.register(
            UINib(nibName: documentCellIdentifier, bundle: nil),
            forCellReuseIdentifier: documentCellIdentifier
        )

        TableView.separatorStyle = .none
        TableView.showsVerticalScrollIndicator = false
        
        // Disable cell selection/tapping
        TableView.allowsSelection = false
    }

    // MARK: - Top View / Staff Setup

    private func setupTopView() {
        topVw.isHidden = false
    }

    // MARK: - Setup Notification Button

    private func setupNotificationButton() {
        NotificationButton.addTarget(
            self,
            action: #selector(notificationButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Setup Back Button

    private func setupBackButton() {
        BackButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Back Button Action

    @objc private func backButtonTapped() {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Notification Button Action

    @objc private func notificationButtonTapped() {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let notificationVC = storyboard.instantiateViewController(
            withIdentifier: "NotificationVC"
        ) as? NotificationVC {

            notificationVC.hidesBottomBarWhenPushed = true

            if let nav = navigationController {

                nav.setNavigationBarHidden(
                    true,
                    animated: false
                )

                nav.pushViewController(
                    notificationVC,
                    animated: true
                )

            } else {

                notificationVC.modalPresentationStyle = .fullScreen

                present(
                    notificationVC,
                    animated: true
                )
            }
        }
    }
    
    // MARK: - API: Fetch Student Profile
    
    private func fetchStudentProfile() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty, !schoolId.isEmpty else {
            print("❌ Profile: Missing schoolId or studentId")
            return
        }

        let requestURL = API.STUDENT_PROFILE + studentId

        NetworkManager.shared.request(
            urlString: requestURL,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<StudentProfileData>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.profileData = data
                        self.loadedStudentId = studentId
                        print("✅ Student Profile parsed successfully for \(data.name)")
                    } else {
                        self.profileData = nil
                    }
                case .failure(let error):
                    print("❌ Student Profile API request failed: \(error)")
                    self.profileData = nil
                }
                self.TableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension StudentprofileVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return 2
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        if indexPath.row == 0 {
            return 1700
        } else {
            return 100
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath
            ) as! StudentdetailsTableViewCell

            if let data = profileData {
                cell.configure(with: data)
            } else {
                cell.clearAllFields()
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: documentCellIdentifier,
                for: indexPath
            ) as! DocumentsTableViewCell2
            
            // Configure DocumentsTableViewCell2 cell if needed here
            
            return cell
        }
    }
    
    // Optional: Ensure no action on tap (extra safety)
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
