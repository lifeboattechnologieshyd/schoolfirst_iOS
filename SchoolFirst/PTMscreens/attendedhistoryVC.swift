//
//  attendedhistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/07/26.
//

import UIKit

class attendedhistoryVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Data
    private var completedData: PTMCompletedMeetingsResponse?
    private var attendedMeetings: [PTMCompletedMeeting] = []
    private var isLoading: Bool = true

    // MARK: - Empty State Label
    private var emptyStateLabel: UILabel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
        setupEmptyStateLabel()
        fetchAttendedMeetings()
    }

    // MARK: - Actions
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - TableView Setup
    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false

        tableview.register(
            UINib(
                nibName: "PTMpastmeetingTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "PTMpastmeetingTableViewCell"
        )
    }

    // MARK: - TopView Shadow
    private func setupTopViewShadow() {

        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }

    // MARK: - Empty State Label Setup
    private func setupEmptyStateLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Attended Meetings"
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.isHidden = true

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])

        self.emptyStateLabel = label
    }

    // MARK: - API: Fetch Attended (Completed) Meetings
    private func fetchAttendedMeetings() {
        isLoading = true
        tableview.reloadData()

        let schoolId  = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        print("📡 attendedhistoryVC | fetchAttendedMeetings")
        print("   schoolId  : \(schoolId)")
        print("   studentId : \(studentId)")

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("❌ attendedhistoryVC: Missing schoolId or studentId")
            isLoading = false
            attendedMeetings = []
            tableview.reloadData()
            updateEmptyState()
            return
        }

        // ✅ Append student_id as query param to prevent 400 Bad Request
        let baseUrl = API.PTM_COMPLETED_MEETINGS
        let urlString = baseUrl.contains("?")
            ? "\(baseUrl)&student_id=\(studentId)"
            : "\(baseUrl)?student_id=\(studentId)"

        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<PTMCompletedMeetingsResponse>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("✅ Attended Meetings API success")
                    print("   description: \(response.description)")
                    if response.success, let data = response.data {
                        self.completedData = data

                        // ✅ Filter only ATTENDED meetings from response array
                        self.attendedMeetings = data.meetings.filter { meeting in
                            let status = meeting.attendanceStatus.uppercased()
                            return status == "ATTENDED" || meeting.isAttended
                        }

                        print("   Total completed : \(data.meetings.count)")
                        print("   Attended count  : \(self.attendedMeetings.count)")
                    } else {
                        self.attendedMeetings = []
                    }
                case .failure(let error):
                    print("❌ Attended Meetings API failed: \(error)")
                    self.attendedMeetings = []
                }
                self.tableview.reloadData()
                self.updateEmptyState()
            }
        }
    }

    // MARK: - Empty State Handler
    private func updateEmptyState() {
        if isLoading {
            emptyStateLabel?.isHidden = true
            tableview.isHidden = false
            return
        }

        if attendedMeetings.isEmpty {
            emptyStateLabel?.isHidden = false
            tableview.isHidden = true
        } else {
            emptyStateLabel?.isHidden = true
            tableview.isHidden = false
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension attendedhistoryVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if isLoading { return 0 }
        return attendedMeetings.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PTMpastmeetingTableViewCell",
            for: indexPath
        ) as! PTMpastmeetingTableViewCell

        cell.selectionStyle = .none

        guard indexPath.row < attendedMeetings.count else {
            return cell
        }

        let meeting = attendedMeetings[indexPath.row]
        
        // ✅ FIX: Changed .studentName to .name to resolve error
        let studentName = UserManager.shared.selectedKid?.name ?? "Student"

        cell.configure(with: meeting, studentName: studentName)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 150
    }
}
