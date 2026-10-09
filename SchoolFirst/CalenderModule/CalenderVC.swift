//
//  CalenderVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

import UIKit

// MARK: - Local dummy model (no API required)
struct DummyCalendarEvent {
    let eventDate: String       // yyyy-MM-dd
    let eventType: String       // FEE, EXAM, EVENT, etc.
    let title: String
    let formattedTimeRange: String?
}


class CalenderVC: UIViewController {

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Dummy Data (no API call)
    private var allEvents: [DummyCalendarEvent] = []

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
        loadDummyCalendarEvents()
    }

    // MARK: - Dummy Events
    private func loadDummyCalendarEvents() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "yyyy-MM-dd"

        func dateString(daysFromToday days: Int) -> String {
            let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
            return formatter.string(from: date)
        }

        allEvents = [
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 0), eventType: "FEE", title: "Fee Payment Reminder", formattedTimeRange: "All Day"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 1), eventType: "EXAM", title: "Mathematics Exam", formattedTimeRange: "09:00 AM – 12:00 PM"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 2), eventType: "HOLIDAY", title: "School Holiday", formattedTimeRange: "All Day"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 3), eventType: "PTM", title: "Parent Teacher Meeting", formattedTimeRange: "03:30 PM – 04:30 PM"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 4), eventType: "HOMEWORK", title: "Science Homework", formattedTimeRange: "Submit by end of day"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 5), eventType: "ASSIGNMENT", title: "English Assignment", formattedTimeRange: "All Day"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 6), eventType: "TRANSPORT", title: "Transport Schedule Update", formattedTimeRange: "08:00 AM"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 7), eventType: "EVENT", title: "Annual Sports Day", formattedTimeRange: "10:00 AM – 02:00 PM"),
            // Same date has multiple event types, so it appears multi-coloured.
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 3), eventType: "EVENT", title: "School Cultural Event", formattedTimeRange: "11:00 AM – 01:00 PM"),
            DummyCalendarEvent(eventDate: dateString(daysFromToday: 3), eventType: "FEE", title: "Fee Counter Open", formattedTimeRange: "09:00 AM – 01:00 PM")
        ]

        tableview.reloadData()
        print("📅 Loaded \(allEvents.count) dummy calendar events")
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
            self?.navigateToMultipleEventsVC()
        }

        // 🟣 Purple → Homework
        cell.onHomeworkTapped = { [weak self] in
            self?.navigateToMultipleEventsVC()
        }

        // 🩵 Sky-blue → Assignment
        cell.onAssignmentTapped = { [weak self] in
            self?.navigateToMultipleEventsVC()
        }

        // 🔵 Blue → Transport
        cell.onTransportTapped = { [weak self] in
            self?.navigateToMultipleEventsVC()
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
