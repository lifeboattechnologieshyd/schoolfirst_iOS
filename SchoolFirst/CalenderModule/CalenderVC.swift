import UIKit
import FSCalendar

class CalenderVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Properties
    private var allEvents: [SchoolCalendarEvent] = []
    private var selectedDate: Date = Date()
    private var selectedDateEvents: [SchoolCalendarEvent] = []

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.systemGray
        return indicator
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchCalendarEvents()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false

        // IMPORTANT: cell height collapse fix
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 750

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.register(
            UINib(nibName: "CalenderVCTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "CalenderVCTableViewCell1"
        )
    }

    // MARK: - API Call
    private func fetchCalendarEvents() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {
            AlertManager.shared.showAlert(title: "Error", message: "Student ID not found.")
            return
        }

        activityIndicator.startAnimating()

        let headers: [String: String] = ["X-School-Id": schoolId]
        let parameters: [String: Any] = ["student_id": studentId]

        NetworkManager.shared.request(
            urlString: API.CALENDAR_EVENTS,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<[SchoolCalendarEvent]>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()

                switch result {
                case .success(let response):
                    self.allEvents = response.data ?? []
                    print("✅ Calendar events loaded: \(self.allEvents.count)")
                    self.tableView.reloadData()

                case .failure(let error):
                    print("❌ Calendar API error: \(error.localizedDescription)")
                    AlertManager.shared.showAlert(
                        title: "Error",
                        message: error.localizedDescription
                    )
                    // empty ayina calendar UI show avvali
                    self.allEvents = []
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Navigation Helpers
    private func navigateToFees() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ParentfeeVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToHomework() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeworkVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToExams() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ExamVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToPTM() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PTMVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToAssignments() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssignmentVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToTransport() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TransportVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Actions (Supports both Capital 'B' & small 'b' from Storyboard)
    @objc @IBAction func BackButtonTapped(_ sender: Any) {
        handleBackNavigation()
    }

  

    private func handleBackNavigation() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension CalenderVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Fixed height for cell content visibility
        return 750
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CalenderVCTableViewCell1",
            for: indexPath
        ) as? CalenderVCTableViewCell1 else {
            return UITableViewCell()
        }

        cell.configure(with: allEvents)

        cell.onFeeEventDateTapped = { [weak self] in
            self?.navigateToFees()
        }
        cell.onHomeworkTapped = { [weak self] in
            self?.navigateToHomework()
        }
        cell.onExamEventTapped = { [weak self] in
            self?.navigateToExams()
        }
        cell.onPTMeetingTapped = { [weak self] in
            self?.navigateToPTM()
        }
        cell.onAssignmentTapped = { [weak self] in
            self?.navigateToAssignments()
        }
        cell.onTransportTapped = { [weak self] in
            self?.navigateToTransport()
        }
        cell.onDateSelected = { [weak self] date, events in
            self?.selectedDate = date
            self?.selectedDateEvents = events
            print("📅 Date selected: \(date), events: \(events.count)")
        }

        cell.selectionStyle = .none
        return cell
    }
}
