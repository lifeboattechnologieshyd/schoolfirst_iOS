import UIKit
import FSCalendar

class CalenderVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Properties
    private var allEvents: [CalendarEventItem] = []
    private var selectedDate: Date = Date()
    private var selectedDateEvents: [CalendarEventItem] = []
    
    // Dynamic Academic Data
    private var currentTermName: String = "Term 2"
    private var currentAcademicYear: String = "2026-2027"

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
        fetchAcademicCalendar()
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

        // Automatic dimension for dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 850

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.register(
            UINib(nibName: "CalenderVCTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "CalenderVCTableViewCell1"
        )
    }
    
    // MARK: - API Calls
    
    private func fetchAcademicCalendar() {
        let schoolId = UserManager.shared.resolvedSchoolID

        guard !schoolId.isEmpty else { return }

        let headers: [String: String] = ["X-School-Id": schoolId]

        NetworkManager.shared.request(
            urlString: API.ACADEMIC_CALENDAR,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<[AcademicCalendarItem]>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let calendars = response.data ?? []
                    // Find the ACTIVE calendar, or fallback to the first one
                    if let activeCalendar = calendars.first(where: { $0.status == "ACTIVE" }) ?? calendars.first {
                        if let term = activeCalendar.term?.name {
                            self.currentTermName = term
                        }
                        if let year = activeCalendar.academicYear?.name {
                            self.currentAcademicYear = year
                        }
                        print("✅ Academic Calendar loaded: \(self.currentTermName), \(self.currentAcademicYear)")
                        self.tableView.reloadData()
                    }

                case .failure(let error):
                    print("❌ Academic Calendar API error: \(error.localizedDescription)")
                }
            }
        }
    }

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
        ) { [weak self] (result: Result<APIResponse<[CalendarEventItem]>, NetworkError>) in
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
                    self.allEvents = []
                    self.tableView.reloadData()
                }
            }
        }
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
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CalenderVCTableViewCell1",
            for: indexPath
        ) as? CalenderVCTableViewCell1 else {
            return UITableViewCell()
        }

        // Pass events, plus the dynamically fetched term and academic year
        cell.configure(
            with: allEvents,
            termName: currentTermName,
            academicYear: currentAcademicYear
        )

        // Only update selected date state; do not navigate away on date tap
        cell.onDateSelected = { [weak self] date, events in
            self?.selectedDate = date
            self?.selectedDateEvents = events
            print("📅 Date selected: \(date), events: \(events.count)")
        }

        cell.selectionStyle = .none
        return cell
    }
}
