//
//  CalenderVCTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 03/06/26.
//

import UIKit
import FSCalendar

class CalenderVCTableViewCell1: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var Goodmorningwithstudentnamelabel: UILabel!
    @IBOutlet weak var Subtitlelabel: UILabel?
    @IBOutlet weak var TodayeventsContainerview: UIView!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var Jumptotodaybutton: UIButton?

    // MARK: - Calendar Container Card
    private let calendarCardView = UIView()

    // MARK: - Custom Month Header Views
    private let headerContainerView = UIView()
    private let monthYearLabel = UILabel()
    private let eventTodayLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    // MARK: - Today's Focus Views
    private let focusHeaderView = UIView()
    private let focusSectionTitleLabel = UILabel()
    private let sparkleImageView = UIImageView()
    private let focusCardsStackView = UIStackView()

    // MARK: - Callbacks
    var onDateSelected: ((_ date: Date, _ events: [CalendarEventItem]) -> Void)?

    // MARK: - Properties & Storage
    private var apiEvents: [CalendarEventItem] = []
    private var eventsByDate: [String: [CalendarEventItem]] = [:]
    private var selectedDate: Date = Date()
    private var didSetupLayout = false
    
    // Dynamic subtitle properties
    private var currentTermName: String = ""
    private var currentAcademicYear: String = ""

    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white

        setupCalendar()
        setupUnifiedLayout()
        updateMonthLabel()
        updateGreetingLabel()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        updateGreetingLabel()
    }

    // MARK: - Unified Auto Layout
    private func setupUnifiedLayout() {
        guard !didSetupLayout else { return }
        didSetupLayout = true

        guard let calendarView = calendarView,
              let todayContainer = TodayeventsContainerview,
              let greetingLabel = Goodmorningwithstudentnamelabel else {
            return
        }

        // 1. Remove all subviews from todayContainer in case of XIB leftovers
        todayContainer.subviews.forEach { $0.removeFromSuperview() }

        // Deactivate existing conflicting constraints on calendar and todayContainer
        contentView.constraints.forEach { c in
            if c.firstItem as? UIView == calendarView || c.secondItem as? UIView == calendarView ||
               c.firstItem as? UIView == todayContainer || c.secondItem as? UIView == todayContainer {
                c.isActive = false
            }
        }
        calendarView.constraints.forEach { $0.isActive = false }
        todayContainer.constraints.forEach { $0.isActive = false }

        // 2. Greeting & Subtitle Layout
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.bringSubviewToFront(greetingLabel)

        let subtitle = Subtitlelabel ?? UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        if Subtitlelabel == nil {
            contentView.addSubview(subtitle)
            Subtitlelabel = subtitle
        }
        contentView.bringSubviewToFront(subtitle)

        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            subtitle.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor)
        ])

        // 3. Calendar Card Setup (Light Sky Blue Card)
        calendarCardView.translatesAutoresizingMaskIntoConstraints = false
        calendarCardView.backgroundColor = UIColor(red: 240/255, green: 246/255, blue: 252/255, alpha: 1.0)
        calendarCardView.layer.cornerRadius = 24
        calendarCardView.clipsToBounds = true
        contentView.addSubview(calendarCardView)

        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.backgroundColor = .clear
        calendarCardView.addSubview(headerContainerView)

        monthYearLabel.translatesAutoresizingMaskIntoConstraints = false
        monthYearLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        monthYearLabel.textColor = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
        headerContainerView.addSubview(monthYearLabel)

        eventTodayLabel.translatesAutoresizingMaskIntoConstraints = false
        eventTodayLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        eventTodayLabel.textColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1.0)
        eventTodayLabel.text = "1 Event Today"
        headerContainerView.addSubview(eventTodayLabel)

        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        let leftImg = UIImage(systemName: "chevron.left", withConfiguration: chevronConfig)
        let rightImg = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)

        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.setImage(leftImg, for: .normal)
        previousButton.tintColor = UIColor(red: 45/255, green: 55/255, blue: 72/255, alpha: 1.0)
        previousButton.backgroundColor = UIColor(red: 250/255, green: 242/255, blue: 190/255, alpha: 1.0)
        previousButton.layer.cornerRadius = 18
        previousButton.clipsToBounds = true
        previousButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        headerContainerView.addSubview(previousButton)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(rightImg, for: .normal)
        nextButton.tintColor = UIColor(red: 45/255, green: 55/255, blue: 72/255, alpha: 1.0)
        nextButton.backgroundColor = UIColor(red: 250/255, green: 242/255, blue: 190/255, alpha: 1.0)
        nextButton.layer.cornerRadius = 18
        nextButton.clipsToBounds = true
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        headerContainerView.addSubview(nextButton)

        calendarView.removeFromSuperview()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = .clear
        calendarCardView.addSubview(calendarView)

        NSLayoutConstraint.activate([
            calendarCardView.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 18),
            calendarCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            calendarCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            headerContainerView.topAnchor.constraint(equalTo: calendarCardView.topAnchor, constant: 16),
            headerContainerView.leadingAnchor.constraint(equalTo: calendarCardView.leadingAnchor, constant: 16),
            headerContainerView.trailingAnchor.constraint(equalTo: calendarCardView.trailingAnchor, constant: -16),
            headerContainerView.heightAnchor.constraint(equalToConstant: 48),

            monthYearLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            monthYearLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),

            eventTodayLabel.topAnchor.constraint(equalTo: monthYearLabel.bottomAnchor, constant: 2),
            eventTodayLabel.leadingAnchor.constraint(equalTo: monthYearLabel.leadingAnchor),

            nextButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: monthYearLabel.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 36),
            nextButton.heightAnchor.constraint(equalToConstant: 36),

            previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -8),
            previousButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),
            previousButton.widthAnchor.constraint(equalToConstant: 36),
            previousButton.heightAnchor.constraint(equalToConstant: 36),

            calendarView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 8),
            calendarView.leadingAnchor.constraint(equalTo: calendarCardView.leadingAnchor, constant: 8),
            calendarView.trailingAnchor.constraint(equalTo: calendarCardView.trailingAnchor, constant: -8),
            calendarView.heightAnchor.constraint(equalToConstant: 310),
            calendarView.bottomAnchor.constraint(equalTo: calendarCardView.bottomAnchor, constant: -12)
        ])

        // 4. Today Focus Container
        todayContainer.translatesAutoresizingMaskIntoConstraints = false
        todayContainer.backgroundColor = UIColor(red: 255/255, green: 249/255, blue: 206/255, alpha: 1.0)
        todayContainer.layer.cornerRadius = 24
        todayContainer.clipsToBounds = true

        focusHeaderView.translatesAutoresizingMaskIntoConstraints = false
        focusHeaderView.backgroundColor = .clear
        todayContainer.addSubview(focusHeaderView)

        focusSectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        focusSectionTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        focusSectionTitleLabel.textColor = UIColor(red: 92/255, green: 68/255, blue: 30/255, alpha: 1.0)
        focusSectionTitleLabel.text = "Today's Focus"
        focusHeaderView.addSubview(focusSectionTitleLabel)

        sparkleImageView.translatesAutoresizingMaskIntoConstraints = false
        sparkleImageView.image = UIImage(named: "stars") ?? UIImage(systemName: "sparkles")
        sparkleImageView.tintColor = UIColor(red: 92/255, green: 68/255, blue: 30/255, alpha: 1.0)
        sparkleImageView.contentMode = .scaleAspectFit
        focusHeaderView.addSubview(sparkleImageView)

        focusCardsStackView.translatesAutoresizingMaskIntoConstraints = false
        focusCardsStackView.axis = .vertical
        focusCardsStackView.spacing = 12
        focusCardsStackView.alignment = .fill
        focusCardsStackView.distribution = .fill
        todayContainer.addSubview(focusCardsStackView)

        NSLayoutConstraint.activate([
            todayContainer.topAnchor.constraint(equalTo: calendarCardView.bottomAnchor, constant: 18),
            todayContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            todayContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            focusHeaderView.topAnchor.constraint(equalTo: todayContainer.topAnchor, constant: 16),
            focusHeaderView.leadingAnchor.constraint(equalTo: todayContainer.leadingAnchor, constant: 18),
            focusHeaderView.trailingAnchor.constraint(equalTo: todayContainer.trailingAnchor, constant: -18),
            focusHeaderView.heightAnchor.constraint(equalToConstant: 28),

            focusSectionTitleLabel.leadingAnchor.constraint(equalTo: focusHeaderView.leadingAnchor),
            focusSectionTitleLabel.centerYAnchor.constraint(equalTo: focusHeaderView.centerYAnchor),

            sparkleImageView.trailingAnchor.constraint(equalTo: focusHeaderView.trailingAnchor),
            sparkleImageView.centerYAnchor.constraint(equalTo: focusHeaderView.centerYAnchor),
            sparkleImageView.widthAnchor.constraint(equalToConstant: 22),
            sparkleImageView.heightAnchor.constraint(equalToConstant: 22),

            focusCardsStackView.topAnchor.constraint(equalTo: focusHeaderView.bottomAnchor, constant: 12),
            focusCardsStackView.leadingAnchor.constraint(equalTo: todayContainer.leadingAnchor, constant: 16),
            focusCardsStackView.trailingAnchor.constraint(equalTo: todayContainer.trailingAnchor, constant: -16),
            focusCardsStackView.bottomAnchor.constraint(equalTo: todayContainer.bottomAnchor, constant: -16)
        ])

        // 5. Jump to Today Pill Button — title kept on ONE line
        let jumpButton = Jumptotodaybutton ?? UIButton(type: .system)
        jumpButton.translatesAutoresizingMaskIntoConstraints = false
        jumpButton.backgroundColor = UIColor(red: 250/255, green: 247/255, blue: 237/255, alpha: 1.0)
        jumpButton.layer.cornerRadius = 22
        jumpButton.layer.borderWidth = 1
        jumpButton.layer.borderColor = UIColor(red: 209/255, green: 213/255, blue: 219/255, alpha: 1.0).cgColor
        jumpButton.clipsToBounds = true
        jumpButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        jumpButton.setTitle("  Jump to Today", for: .normal)
        jumpButton.setTitleColor(UIColor(red: 45/255, green: 76/255, blue: 62/255, alpha: 1.0), for: .normal)
        jumpButton.tintColor = UIColor(red: 45/255, green: 76/255, blue: 62/255, alpha: 1.0)
        jumpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        // Force single-line title
        jumpButton.titleLabel?.numberOfLines = 1
        jumpButton.titleLabel?.lineBreakMode = .byClipping
        jumpButton.titleLabel?.adjustsFontSizeToFitWidth = true
        jumpButton.titleLabel?.minimumScaleFactor = 0.85
        jumpButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        jumpButton.addTarget(self, action: #selector(didTapJumpToToday), for: .touchUpInside)

        if Jumptotodaybutton == nil {
            contentView.addSubview(jumpButton)
            Jumptotodaybutton = jumpButton
        }

        NSLayoutConstraint.activate([
            jumpButton.topAnchor.constraint(equalTo: todayContainer.bottomAnchor, constant: 16),
            jumpButton.trailingAnchor.constraint(equalTo: todayContainer.trailingAnchor),
            jumpButton.widthAnchor.constraint(equalToConstant: 175),
            jumpButton.heightAnchor.constraint(equalToConstant: 44),
            jumpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - FSCalendar Setup
    private func setupCalendar() {
        guard let calendarView = calendarView else { return }

        calendarView.delegate = self
        calendarView.dataSource = self

        calendarView.scope = .month
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
        calendarView.headerHeight = 0
        calendarView.firstWeekday = 2

        calendarView.appearance.weekdayTextColor = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1.0)
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        calendarView.appearance.caseOptions = .weekdayUsesUpperCase

        calendarView.appearance.titleDefaultColor = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
        calendarView.appearance.titlePlaceholderColor = UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1.0)
        calendarView.appearance.titleWeekendColor = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)

        calendarView.appearance.todayColor = .clear
        calendarView.appearance.titleTodayColor = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
        calendarView.appearance.selectionColor = .clear
        calendarView.appearance.titleSelectionColor = .white

        calendarView.register(
            MultiColorCalendarCell.self,
            forCellReuseIdentifier: "MultiColorCalendarCell"
        )

        calendarView.rowHeight = 44
    }

    // MARK: - Configure with API Events
    func configure(with events: [CalendarEventItem], termName: String, academicYear: String) {
        self.apiEvents = events
        self.currentTermName = termName
        self.currentAcademicYear = academicYear
        buildEventsByDateCache()

        updateGreetingLabel()
        updateMonthLabel()
        updateEventCountLabel()

        calendarView?.select(selectedDate)
        let currentEvents = eventsForDate(selectedDate)
        updateBottomCards(for: selectedDate, events: currentEvents)

        calendarView?.reloadData()
    }

    // MARK: - Greeting & Term
    private func updateGreetingLabel() {
        let studentName = UserManager.shared.resolvedStudentName
        let greeting = greetingForCurrentTime()
        Goodmorningwithstudentnamelabel?.text = "\(greeting), \(studentName)"
        Goodmorningwithstudentnamelabel?.font = .systemFont(ofSize: 24, weight: .bold)
        Goodmorningwithstudentnamelabel?.textColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)

        // Now dynamically using API values passed in via configure()
        let termText = currentTermName.isEmpty ? "Term" : currentTermName
        let yearText = currentAcademicYear.isEmpty ? "" : currentAcademicYear
        
        Subtitlelabel?.text = "\(termText) • Academic Year \(yearText)"
        Subtitlelabel?.font = .systemFont(ofSize: 15, weight: .regular)
        Subtitlelabel?.textColor = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1.0)
    }

    private func greetingForCurrentTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    // MARK: - Event Cache
    private func dateKey(from dateString: String) -> String? {
        let trimmed = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if trimmed.count >= 10 {
            let candidate = String(trimmed.prefix(10))
            let parts = candidate.split(separator: "-")
            if parts.count == 3, parts[0].count == 4, parts[1].count == 2, parts[2].count == 2 {
                return candidate
            }
        }

        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd",
            "dd-MM-yyyy"
        ]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for fmt in formatters {
            df.dateFormat = fmt
            if let d = df.date(from: trimmed) {
                return apiDateFormatter.string(from: d)
            }
        }
        return trimmed
    }

    private func buildEventsByDateCache() {
        var map: [String: [CalendarEventItem]] = [:]
        for event in apiEvents {
            if let rawDate = event.eventDate, let key = dateKey(from: rawDate) {
                map[key, default: []].append(event)
            }
        }
        eventsByDate = map
    }

    private func eventsForDate(_ date: Date) -> [CalendarEventItem] {
        let key = apiDateFormatter.string(from: date)
        return eventsByDate[key] ?? []
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        guard let calendarView = calendarView else { return false }
        return Calendar.current.isDate(date, equalTo: calendarView.currentPage, toGranularity: .month)
    }

    // MARK: - Header Actions & Labels
    @objc private func previousMonthTapped() { moveMonth(by: -1) }
    @objc private func nextMonthTapped()     { moveMonth(by: 1) }

    private func moveMonth(by value: Int) {
        guard let calendarView = calendarView else { return }
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: calendarView.currentPage) {
            calendarView.setCurrentPage(newDate, animated: true)
            updateMonthLabel()
        }
    }

    private func updateMonthLabel() {
        guard let calendarView = calendarView else { return }
        monthYearLabel.text = monthYearFormatter.string(from: calendarView.currentPage)
    }

    private func updateEventCountLabel() {
        let todayEvents = eventsForDate(Date())
        if todayEvents.count == 1 {
            eventTodayLabel.text = "1 Event Today"
        } else if todayEvents.isEmpty {
            eventTodayLabel.text = "No Events Today"
        } else {
            eventTodayLabel.text = "\(todayEvents.count) Events Today"
        }
    }

    // MARK: - Jump to Today Action
    @objc private func didTapJumpToToday() {
        let today = Date()
        selectedDate = today
        calendarView?.setCurrentPage(today, animated: true)
        calendarView?.select(today)
        updateMonthLabel()
        updateEventCountLabel()

        let todayEvents = eventsForDate(today)
        updateBottomCards(for: today, events: todayEvents)
        onDateSelected?(today, todayEvents)
        calendarView?.reloadData()
    }

    // MARK: - Bottom Focus Cards
    private func updateBottomCards(for date: Date, events: [CalendarEventItem]) {
        if Calendar.current.isDateInToday(date) {
            focusSectionTitleLabel.text = "Today's Focus"
        } else {
            let df = DateFormatter()
            df.dateFormat = "dd MMM"
            focusSectionTitleLabel.text = "Focus for \(df.string(from: date))"
        }

        focusCardsStackView.arrangedSubviews.forEach {
            focusCardsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if events.isEmpty {
            let emptyCard = createEventCard(
                title: "No events on this day",
                subtitle: "Enjoy your day!",
                color: UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1.0),
                isPlaceholder: true
            )
            focusCardsStackView.addArrangedSubview(emptyCard)
        } else {
            for event in events {
                let card = createEventCard(
                    title: event.title ?? "Event",
                    subtitle: event.subtitleDisplayText,
                    color: event.uiColor,
                    isPlaceholder: false
                )
                focusCardsStackView.addArrangedSubview(card)
            }
        }
    }

    private func createEventCard(
        title: String,
        subtitle: String,
        color: UIColor,
        isPlaceholder: Bool
    ) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.clipsToBounds = true

        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = isPlaceholder
            ? UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0)
            : color.withAlphaComponent(0.18)
        iconCircle.layer.cornerRadius = 22
        iconCircle.clipsToBounds = true
        card.addSubview(iconCircle)

        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let calendarImg = UIImage(systemName: "calendar") ?? UIImage(named: "calender")
        iconView.image = isPlaceholder ? UIImage(systemName: "checkmark.circle") : calendarImg
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconCircle.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0)
        card.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1.0)
        card.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 76),

            iconCircle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconCircle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 44),
            iconCircle.heightAnchor.constraint(equalToConstant: 44),

            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])

        return card
    }
}

// MARK: - FSCalendar Delegate, DataSource & DelegateAppearance
extension CalenderVCTableViewCell1: FSCalendarDelegate,
                                     FSCalendarDataSource,
                                     FSCalendarDelegateAppearance {

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
        calendar.reloadData()
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {
        guard isCurrentMonth(date) else {
            return UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1.0)
        }
        let isSelectedDate = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let dayEvents = eventsForDate(date)
        if !dayEvents.isEmpty || isSelectedDate {
            return .white
        }
        return UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        fillDefaultColorFor date: Date
    ) -> UIColor? {
        return .clear
    }

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

        let dayEvents = eventsForDate(date)
        let isCurrent = (position == .current) || isCurrentMonth(date)
        let isSelectedDate = Calendar.current.isDate(date, inSameDayAs: selectedDate)

        cell.isDateSelected = isSelectedDate && isCurrent

        if !dayEvents.isEmpty && isCurrent {
            let colors = dayEvents.map { $0.uiColor }
            cell.showMultiColorWithColors(colors)
        } else {
            cell.showMultiColor(false)
        }

        return cell
    }

    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        selectedDate = date
        let dayEvents = eventsForDate(date)

        updateBottomCards(for: date, events: dayEvents)

        onDateSelected?(date, dayEvents)
        calendar.reloadData()
    }
}
