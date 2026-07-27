//
//  CalenderVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

import UIKit

class CalenderVC: UIViewController {

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Data
    private var allEvents: [CalendarEvent] = []
    private var isLoading: Bool = true
    private var loadedStudentId: String = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TopView.addBottomOnlyShadow(
                color: .lightGray,
                opacity: 0.4,
                radius: 4,
                height: 6
            )
        setupTableView()
        fetchCalendarEvents()
    }

    // MARK: - Reload on Student Switch
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentStudentId = UserManager.shared.resolvedStudentID
        if currentStudentId != loadedStudentId && !currentStudentId.isEmpty {
            print("🔄 Calendar: Student changed to: \(currentStudentId)")
            fetchCalendarEvents()
        }
    }

    // MARK: - Fetch Calendar Events API
    private func fetchCalendarEvents() {
        isLoading = true

        let studentId = UserManager.shared.resolvedStudentID
        let schoolId   = UserManager.shared.resolvedSchoolID

        print("📡 CalendarVC fetchEvents | schoolId: \(schoolId) | studentId: \(studentId)")

        guard !schoolId.isEmpty else {
            print("❌ CalendarVC: Missing schoolId")
            isLoading = false
            return
        }

        var parameters: [String: Any] = [:]
        if !studentId.isEmpty {
            parameters["student_id"] = studentId
        }

        NetworkManager.shared.request(
            urlString: API.CALENDAR_EVENTS,
            method: .GET,
            requiresAuth: true,
            parameters: parameters.isEmpty ? nil : parameters,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<[CalendarEvent]>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.allEvents = data
                        self.loadedStudentId = studentId
                        print("✅ Calendar events loaded: \(data.count)")
                        for event in data {
                            print("   📌 \(event.eventDate) | \(event.eventType) | \(event.title)")
                        }
                    } else {
                        self.allEvents = []
                    }
                case .failure(let error):
                    print("❌ Calendar events API failed: \(error)")
                    self.allEvents = []
                }
                self.tableview.reloadData()
            }
        }
    }
    
    @IBAction func NotificationButtonTapped(_ sender: UIButton) {
        navigateToNotificationVC()
    }
    
    private func navigateToNotificationVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let notificationVC = storyboard.instantiateViewController(
            withIdentifier: "NotificationVC"
        ) as? NotificationVC {

            notificationVC.hidesBottomBarWhenPushed = true

            navigationController?.pushViewController(
                notificationVC,
                animated: true
            )
        }
    }

    // MARK: - BackButton Action

    @IBAction func BackButtonTapped(_ sender: UIButton) {

        navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "CalenderVCTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "CalenderVCTableViewCell1"
        )

        tableview.separatorStyle = .none
    }

    // MARK: - Navigation Methods

    private func navigateToStudentProfileVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let profileVC = storyboard.instantiateViewController(
            withIdentifier: "StudentprofileVC"
        ) as? StudentprofileVC {

            navigationController?.pushViewController(profileVC, animated: true)
        }
    }

    private func navigateToFeeEventVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let feeEventVC = storyboard.instantiateViewController(
            withIdentifier: "FeeEventVC"
        ) as? FeeEventVC {

            navigationController?.pushViewController(feeEventVC, animated: true)
        }
    }

    private func navigateToAnnualSportsDayVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let sportsVC = storyboard.instantiateViewController(
            withIdentifier: "AnnualsportsdayVC"
        ) as? AnnualsportsdayVC {

            navigationController?.pushViewController(sportsVC, animated: true)
        }
    }

    private func navigateToExamEventVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let examVC = storyboard.instantiateViewController(
            withIdentifier: "ExameventVC"
        ) as? ExameventVC {

            navigationController?.pushViewController(examVC, animated: true)
        }
    }

    private func navigateToPTMeetingVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let ptVC = storyboard.instantiateViewController(
            withIdentifier: "P_TmeetingVC"
        ) as? P_TmeetingVC {

            navigationController?.pushViewController(ptVC, animated: true)
        }
    }
    
    // MARK: - NEW: Navigate to Multiple Events
    
    private func navigateToMultipleEventsVC() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let multiVC = storyboard.instantiateViewController(
            withIdentifier: "MultipleeventsVC"
        ) as? MultipleeventsVC {

            navigationController?.pushViewController(multiVC, animated: true)
        }
    }
}

// MARK: - UITableView Delegate & DataSource

extension CalenderVC: UITableViewDelegate, UITableViewDataSource {

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
            withIdentifier: "CalenderVCTableViewCell1",
            for: indexPath
        ) as! CalenderVCTableViewCell1

        cell.selectionStyle = .none

        // ✅ Pass API events to calendar cell (colors + multi-color handled inside cell)
        cell.configure(with: allEvents)

        // 🟡 Yellow → Fee Event
        cell.onFeeEventDateTapped = { [weak self] in
            self?.navigateToFeeEventVC()
        }

        // 🟢 Green → Annual Sports Day
        cell.onAnnualSportsDayTapped = { [weak self] in
            self?.navigateToAnnualSportsDayVC()
        }

        // 🔴 Red → Exam Event
        cell.onExamEventTapped = { [weak self] in
            self?.navigateToExamEventVC()
        }

        // 🟡 Yellow → P-T Meeting
        cell.onPTMeetingTapped = { [weak self] in
            self?.navigateToPTMeetingVC()
        }
        
        // 🎨 Multi-Color → Multiple Events
        cell.onMultipleEventsTapped = { [weak self] in
            self?.navigateToMultipleEventsVC()
        }

        // 🟢 Green → General Event
        cell.onEventTapped = { [weak self] in
            self?.navigateToAnnualSportsDayVC()
        }

        // 🟠 Orange → Holiday
        cell.onHolidayTapped = { [weak self] in
            print("🟠 Holiday tapped")
        }

        // 🟣 Purple → Homework
        cell.onHomeworkTapped = { [weak self] in
            print("🟣 Homework tapped")
        }

        // 🩵 Sky-blue → Assignment
        cell.onAssignmentTapped = { [weak self] in
            print("🩵 Assignment tapped")
        }

        // 🔵 Blue → Transport
        cell.onTransportTapped = { [weak self] in
            print("🔵 Transport tapped")
        }

        // 📅 Any date selected (with its events)
        cell.onDateSelected = { date, events in
            print("📅 Selected \(date) → \(events.count) event(s)")
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 1200
    }
}
