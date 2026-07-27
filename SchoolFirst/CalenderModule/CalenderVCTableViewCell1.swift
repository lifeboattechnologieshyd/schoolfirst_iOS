//
//  CalenderVCTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 03/06/26.
//

import UIKit
import FSCalendar

class CalenderVCTableViewCell1: UITableViewCell {

    @IBOutlet weak var TodayeventsContainerview: UIView!
    @IBOutlet weak var calendarView: FSCalendar!

    // MARK: - Custom Header Views

    private let headerContainerView = UIView()
    private let monthYearLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    // MARK: - Navigation Callbacks

    var onFeeEventDateTapped: (() -> Void)?
    var onAnnualSportsDayTapped: (() -> Void)?
    var onExamEventTapped: (() -> Void)?
    var onPTMeetingTapped: (() -> Void)?
    var onMultipleEventsTapped: (() -> Void)?
    var onHolidayTapped: (() -> Void)?
    var onHomeworkTapped: (() -> Void)?
    var onAssignmentTapped: (() -> Void)?
    var onTransportTapped: (() -> Void)?
    var onEventTapped: (() -> Void)?
    var onDateSelected: ((_ date: Date, _ events: [CalendarEvent]) -> Void)?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    // MARK: - API Events Storage

    /// All events from API — set via configure(with:)
    private var apiEvents: [CalendarEvent] = []

    /// Cached mapping: "yyyy-MM-dd" → [CalendarEvent]
    private var eventsByDate: [String: [CalendarEvent]] = [:]

    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Event Type → Color Mapping

    private func color(for eventType: String) -> UIColor {
        switch eventType.uppercased() {
        case "PTM":
            return UIColor.systemYellow
        case "FEE":
            return UIColor.systemYellow
        case "EXAM":
            return UIColor.systemRed
        case "HOLIDAY":
            return UIColor.systemOrange
        case "EVENT":
            return UIColor.systemGreen
        case "HOMEWORK":
            return UIColor.systemPurple
        case "ASSIGNMENT":
            return UIColor.systemTeal       // sky-blue
        case "TRANSPORT":
            return UIColor.systemBlue
        default:
            return UIColor.systemGray
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCalendar()
        setupCustomHeader()
        updateMonthLabel()
        setupTodayFocusCards()
    }

    // MARK: - Configure with API Events

    func configure(with events: [CalendarEvent]) {
        self.apiEvents = events
        buildEventsByDateCache()
        calendarView.reloadData()
        updateTodayFocusCards()
    }

    /// Build "yyyy-MM-dd" → [CalendarEvent] cache
    private func buildEventsByDateCache() {
        var map: [String: [CalendarEvent]] = [:]
        for event in apiEvents {
            let key = event.eventDate // "yyyy-MM-dd" from API
            if map[key] != nil {
                map[key]!.append(event)
            } else {
                map[key] = [event]
            }
        }
        eventsByDate = map
        print("📅 CalendarCell: built cache for \(map.count) unique dates from \(apiEvents.count) events")
    }

    /// Get events for a given Date
    private func events(for date: Date) -> [CalendarEvent] {
        let key = apiDateFormatter.string(from: date)
        return eventsByDate[key] ?? []
    }

    /// Check if date is in current month page
    private func isCurrentMonth(_ date: Date) -> Bool {
        return Calendar.current.isDate(
            date,
            equalTo: calendarView.currentPage,
            toGranularity: .month
        )
    }

    // MARK: - Calendar Setup

    private func setupCalendar() {

        calendarView.delegate = self
        calendarView.dataSource = self

        calendarView.scope = .month
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal

        // Hide Default Header
        calendarView.headerHeight = 0
        calendarView.appearance.headerMinimumDissolvedAlpha = 0

        // Background
        calendarView.layer.cornerRadius = 16
        calendarView.clipsToBounds = true

        // Weekdays
        calendarView.appearance.weekdayTextColor = .darkGray
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 13, weight: .medium)

        // Dates
        calendarView.appearance.titleDefaultColor = .black
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.titlePlaceholderColor = .lightGray
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

        // Today Date - Disable default styling
        calendarView.appearance.todayColor = .clear
        calendarView.appearance.titleTodayColor = .black

        // Selected Date - Disable default blue circle
        calendarView.appearance.selectionColor = .clear
        calendarView.appearance.titleSelectionColor = .black

        // Make event dates rounded rectangle (filled)
        calendarView.appearance.borderRadius = 0.4

        // Register the multi-color cell
        calendarView.register(
            MultiColorCalendarCell.self,
            forCellReuseIdentifier: "MultiColorCalendarCell"
        )

        // Adjust row height for better filled look
        calendarView.rowHeight = 48
    }

    // MARK: - Custom Header

    private func setupCustomHeader() {

        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerContainerView)

        // Month Label
        monthYearLabel.translatesAutoresizingMaskIntoConstraints = false
        monthYearLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        monthYearLabel.textColor = .black
        monthYearLabel.textAlignment = .left
        headerContainerView.addSubview(monthYearLabel)

        // Previous Button
        previousButton.translatesAutoresizingMaskIntoConstraints = false

        let previousImage = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .bold
            )
        )

        previousButton.setImage(previousImage, for: .normal)
        previousButton.tintColor = .darkGray

        previousButton.backgroundColor = UIColor(
            red: 245/255,
            green: 236/255,
            blue: 153/255,
            alpha: 1.0
        )

        previousButton.layer.cornerRadius = 16
        previousButton.clipsToBounds = true

        previousButton.addTarget(
            self,
            action: #selector(previousMonthTapped),
            for: .touchUpInside
        )

        headerContainerView.addSubview(previousButton)

        // Next Button
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        let nextImage = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .bold
            )
        )

        nextButton.setImage(nextImage, for: .normal)
        nextButton.tintColor = .darkGray

        nextButton.backgroundColor = UIColor(
            red: 245/255,
            green: 236/255,
            blue: 153/255,
            alpha: 1.0
        )

        nextButton.layer.cornerRadius = 16
        nextButton.clipsToBounds = true

        nextButton.addTarget(
            self,
            action: #selector(nextMonthTapped),
            for: .touchUpInside
        )

        headerContainerView.addSubview(nextButton)

        NSLayoutConstraint.activate([

            headerContainerView.leadingAnchor.constraint(
                equalTo: calendarView.leadingAnchor,
                constant: 12
            ),
            headerContainerView.trailingAnchor.constraint(
                equalTo: calendarView.trailingAnchor,
                constant: -12
            ),
            headerContainerView.bottomAnchor.constraint(
                equalTo: calendarView.topAnchor
            ),
            headerContainerView.heightAnchor.constraint(
                equalToConstant: 40
            ),

            monthYearLabel.leadingAnchor.constraint(
                equalTo: headerContainerView.leadingAnchor
            ),
            monthYearLabel.centerYAnchor.constraint(
                equalTo: headerContainerView.centerYAnchor
            ),

            nextButton.trailingAnchor.constraint(
                equalTo: headerContainerView.trailingAnchor
            ),
            nextButton.centerYAnchor.constraint(
                equalTo: headerContainerView.centerYAnchor
            ),
            nextButton.widthAnchor.constraint(equalToConstant: 32),
            nextButton.heightAnchor.constraint(equalToConstant: 32),

            previousButton.trailingAnchor.constraint(
                equalTo: nextButton.leadingAnchor,
                constant: -8
            ),
            previousButton.centerYAnchor.constraint(
                equalTo: headerContainerView.centerYAnchor
            ),
            previousButton.widthAnchor.constraint(equalToConstant: 32),
            previousButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // MARK: - Button Actions

    @objc private func previousMonthTapped() {
        moveMonth(by: -1)
    }

    @objc private func nextMonthTapped() {
        moveMonth(by: 1)
    }

    private func moveMonth(by value: Int) {

        let currentPage = calendarView.currentPage

        if let newDate = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: currentPage
        ) {
            calendarView.setCurrentPage(newDate, animated: true)
        }
    }

    private func updateMonthLabel() {
        monthYearLabel.text = dateFormatter.string(from: calendarView.currentPage)
    }

    // MARK: - Today Focus Cards

    /// References for dynamic update
    private var todayCard1: UIView?
    private var todayCard2: UIView?
    private var todayTitle1: UILabel?
    private var todaySubtitle1: UILabel?
    private var todayIcon1: UIImageView?
    private var todayIconCircle1: UIView?
    private var todayTitle2: UILabel?
    private var todaySubtitle2: UILabel?
    private var todayIcon2: UIImageView?
    private var todayIconCircle2: UIView?

    /// Update today cards from API events
    private func updateTodayFocusCards() {
        let today = Date()
        let todayEvents = events(for: today)

        if todayEvents.count >= 1 {
            let ev1 = todayEvents[0]
            todayTitle1?.text    = ev1.title
            todaySubtitle1?.text = ev1.formattedTimeRange ?? "All Day"
            todayIcon1?.image    = icon(for: ev1.eventType)
            todayIcon1?.tintColor = color(for: ev1.eventType)
            todayIconCircle1?.backgroundColor = color(for: ev1.eventType).withAlphaComponent(0.15)
            todayCard1?.isHidden = false
        } else {
            todayTitle1?.text    = "No events today"
            todaySubtitle1?.text = "Enjoy your day!"
            todayIcon1?.image    = UIImage(systemName: "checkmark.circle")
            todayIcon1?.tintColor = .systemGreen
            todayIconCircle1?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            todayCard1?.isHidden = false
        }

        if todayEvents.count >= 2 {
            let ev2 = todayEvents[1]
            todayTitle2?.text    = ev2.title
            todaySubtitle2?.text = ev2.formattedTimeRange ?? "All Day"
            todayIcon2?.image    = icon(for: ev2.eventType)
            todayIcon2?.tintColor = color(for: ev2.eventType)
            todayIconCircle2?.backgroundColor = color(for: ev2.eventType).withAlphaComponent(0.15)
            todayCard2?.isHidden = false
        } else {
            todayCard2?.isHidden = true
        }
    }

    /// Event type → SF Symbol icon
    private func icon(for eventType: String) -> UIImage? {
        switch eventType.uppercased() {
        case "PTM":        return UIImage(systemName: "person.2.fill")
        case "FEE":        return UIImage(systemName: "indianrupeesign.circle.fill")
        case "EXAM":       return UIImage(systemName: "doc.text.fill")
        case "HOLIDAY":    return UIImage(systemName: "sun.max.fill")
        case "EVENT":      return UIImage(systemName: "star.fill")
        case "HOMEWORK":   return UIImage(systemName: "book.fill")
        case "ASSIGNMENT": return UIImage(systemName: "pencil.and.list.clipboard")
        case "TRANSPORT":  return UIImage(systemName: "bus.fill")
        default:           return UIImage(systemName: "calendar")
        }
    }

    private func setupTodayFocusCards() {

        let cardBackgroundColor = UIColor(
            red: 241/255,
            green: 236/255,
            blue: 204/255,
            alpha: 1.0
        )

        let card1 = UIView()
        card1.translatesAutoresizingMaskIntoConstraints = false
        card1.backgroundColor = cardBackgroundColor
        card1.layer.cornerRadius = 18
        self.todayCard1 = card1

        let iconCircle1 = UIView()
        iconCircle1.translatesAutoresizingMaskIntoConstraints = false
        iconCircle1.backgroundColor = UIColor(
            red: 244/255,
            green: 213/255,
            blue: 213/255,
            alpha: 1.0
        )
        iconCircle1.layer.cornerRadius = 22
        self.todayIconCircle1 = iconCircle1

        let icon1 = UIImageView()
        icon1.translatesAutoresizingMaskIntoConstraints = false
        icon1.image = UIImage(systemName: "doc.text")
        icon1.tintColor = UIColor.brown
        self.todayIcon1 = icon1

        let title1 = UILabel()
        title1.translatesAutoresizingMaskIntoConstraints = false
        title1.text = "No events today"
        title1.font = .systemFont(ofSize: 18, weight: .medium)
        self.todayTitle1 = title1

        let subtitle1 = UILabel()
        subtitle1.translatesAutoresizingMaskIntoConstraints = false
        subtitle1.text = "Enjoy your day!"
        subtitle1.textColor = .darkGray
        subtitle1.font = .systemFont(ofSize: 14)
        self.todaySubtitle1 = subtitle1

        let card2 = UIView()
        card2.translatesAutoresizingMaskIntoConstraints = false
        card2.backgroundColor = cardBackgroundColor
        card2.layer.cornerRadius = 18
        card2.isHidden = true
        self.todayCard2 = card2

        let iconCircle2 = UIView()
        iconCircle2.translatesAutoresizingMaskIntoConstraints = false
        iconCircle2.backgroundColor = UIColor(
            red: 203/255,
            green: 231/255,
            blue: 255/255,
            alpha: 1.0
        )
        iconCircle2.layer.cornerRadius = 22
        self.todayIconCircle2 = iconCircle2

        let icon2 = UIImageView()
        icon2.translatesAutoresizingMaskIntoConstraints = false
        icon2.image = UIImage(systemName: "person.3.fill")
        icon2.tintColor = .systemTeal
        self.todayIcon2 = icon2

        let title2 = UILabel()
        title2.translatesAutoresizingMaskIntoConstraints = false
        title2.text = "PTA Meeting"
        title2.font = .systemFont(ofSize: 18, weight: .medium)
        self.todayTitle2 = title2

        let subtitle2 = UILabel()
        subtitle2.translatesAutoresizingMaskIntoConstraints = false
        subtitle2.text = "03:30 PM • Main Hall"
        subtitle2.textColor = .darkGray
        subtitle2.font = .systemFont(ofSize: 14)
        self.todaySubtitle2 = subtitle2

        TodayeventsContainerview.addSubview(card1)
        TodayeventsContainerview.addSubview(card2)

        card1.addSubview(iconCircle1)
        iconCircle1.addSubview(icon1)
        card1.addSubview(title1)
        card1.addSubview(subtitle1)

        card2.addSubview(iconCircle2)
        iconCircle2.addSubview(icon2)
        card2.addSubview(title2)
        card2.addSubview(subtitle2)

        NSLayoutConstraint.activate([

            card1.leadingAnchor.constraint(equalTo: TodayeventsContainerview.leadingAnchor, constant: 18),
            card1.trailingAnchor.constraint(equalTo: TodayeventsContainerview.trailingAnchor, constant: -18),
            card1.topAnchor.constraint(equalTo: TodayeventsContainerview.topAnchor, constant: 80),
            card1.heightAnchor.constraint(equalToConstant: 90),

            card2.leadingAnchor.constraint(equalTo: card1.leadingAnchor),
            card2.trailingAnchor.constraint(equalTo: card1.trailingAnchor),
            card2.topAnchor.constraint(equalTo: card1.bottomAnchor, constant: 16),
            card2.heightAnchor.constraint(equalToConstant: 90),

            iconCircle1.leadingAnchor.constraint(equalTo: card1.leadingAnchor, constant: 16),
            iconCircle1.centerYAnchor.constraint(equalTo: card1.centerYAnchor),
            iconCircle1.widthAnchor.constraint(equalToConstant: 44),
            iconCircle1.heightAnchor.constraint(equalToConstant: 44),

            icon1.centerXAnchor.constraint(equalTo: iconCircle1.centerXAnchor),
            icon1.centerYAnchor.constraint(equalTo: iconCircle1.centerYAnchor),

            title1.leadingAnchor.constraint(equalTo: iconCircle1.trailingAnchor, constant: 16),
            title1.topAnchor.constraint(equalTo: card1.topAnchor, constant: 20),

            subtitle1.leadingAnchor.constraint(equalTo: title1.leadingAnchor),
            subtitle1.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 4),

            iconCircle2.leadingAnchor.constraint(equalTo: card2.leadingAnchor, constant: 16),
            iconCircle2.centerYAnchor.constraint(equalTo: card2.centerYAnchor),
            iconCircle2.widthAnchor.constraint(equalToConstant: 44),
            iconCircle2.heightAnchor.constraint(equalToConstant: 44),

            icon2.centerXAnchor.constraint(equalTo: iconCircle2.centerXAnchor),
            icon2.centerYAnchor.constraint(equalTo: iconCircle2.centerYAnchor),

            title2.leadingAnchor.constraint(equalTo: iconCircle2.trailingAnchor, constant: 16),
            title2.topAnchor.constraint(equalTo: card2.topAnchor, constant: 20),

            subtitle2.leadingAnchor.constraint(equalTo: title2.leadingAnchor),
            subtitle2.topAnchor.constraint(equalTo: title2.bottomAnchor, constant: 4)
        ])
    }
}

// MARK: - FSCalendar Delegate

extension CalenderVCTableViewCell1: FSCalendarDelegate,
                                    FSCalendarDataSource,
                                    FSCalendarDelegateAppearance {

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
    }

    // MARK: - Title Color

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {

        guard isCurrentMonth(date) else {
            return .lightGray
        }

        let dayEvents = events(for: date)

        // White text for dates that have events (filled background)
        if !dayEvents.isEmpty {
            return .white
        }

        return .black
    }

    // MARK: - Fill Color for Event Dates

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        fillDefaultColorFor date: Date
    ) -> UIColor? {

        guard isCurrentMonth(date) else { return nil }

        let dayEvents = events(for: date)

        guard !dayEvents.isEmpty else { return nil }

        // Multiple events on same date → handled by custom multi-color cell
        if dayEvents.count > 1 {
            return .clear
        }

        // Single event → fill with event type color
        return color(for: dayEvents[0].eventType)
    }

    // MARK: - Custom Cell for Multi-Color Date

    func calendar(
        _ calendar: FSCalendar,
        cellFor date: Date,
        at position: FSCalendarMonthPosition
    ) -> FSCalendarCell {

        let cell = calendar.dequeueReusableCell(
            withIdentifier: "MultiColorCalendarCell",
            for: date,
            at: position
        ) as! MultiColorCalendarCell

        let dayEvents = events(for: date)
        let isInCurrentMonth = isCurrentMonth(date)

        // Show multi-color only when 2+ events in current month
        if dayEvents.count > 1 && isInCurrentMonth {
            let colors = dayEvents.map { color(for: $0.eventType) }
            cell.showMultiColorWithColors(colors)
        } else {
            cell.showMultiColor(false)
        }

        return cell
    }

    // MARK: - Date Selection

    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {

        let dayEvents = events(for: date)

        // Notify delegate with date & events
        onDateSelected?(date, dayEvents)

        // Multiple events
        if dayEvents.count > 1 {
            onMultipleEventsTapped?()
        } else if let event = dayEvents.first {
            // Single event — trigger specific callback
            switch event.eventType.uppercased() {
            case "FEE":
                onFeeEventDateTapped?()
            case "EVENT":
                onEventTapped?()
            case "EXAM":
                onExamEventTapped?()
            case "PTM":
                onPTMeetingTapped?()
            case "HOLIDAY":
                onHolidayTapped?()
            case "HOMEWORK":
                onHomeworkTapped?()
            case "ASSIGNMENT":
                onAssignmentTapped?()
            case "TRANSPORT":
                onTransportTapped?()
            default:
                break
            }
        }

        // Deselect after small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            calendar.deselect(date)
        }
    }
}
