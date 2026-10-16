//
//  CalenderVCTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 03/06/26.
//

import UIKit
import FSCalendar

class CalenderVCTableViewCell1: UITableViewCell {

    @IBOutlet weak var Goodmorningwithstudentnamelabel: UILabel!
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
    var onDateSelected: ((_ date: Date, _ events: [SchoolCalendarEvent]) -> Void)?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    // MARK: - API Events Storage
    private var apiEvents: [SchoolCalendarEvent] = []
    private var eventsByDate: [String: [SchoolCalendarEvent]] = [:]
    private var didSetupLayout = false

    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Event Color Resolution
    private func color(for event: SchoolCalendarEvent) -> UIColor {
        if let colorStr = event.color?.trimmingCharacters(in: .whitespacesAndNewlines), !colorStr.isEmpty {
            if let parsed = parseColorString(colorStr) {
                return parsed
            }
        }
        return colorByType(event.eventType ?? "")
    }

    private func parseColorString(_ colorStr: String) -> UIColor? {
        let lower = colorStr.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        switch lower {
        case "red":             return UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
        case "green":           return UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)
        case "blue":            return UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0)
        case "yellow":          return UIColor(red: 234/255, green: 179/255, blue: 8/255, alpha: 1.0)
        case "orange":          return UIColor(red: 249/255, green: 115/255, blue: 22/255, alpha: 1.0)
        case "purple":          return UIColor(red: 168/255, green: 85/255, blue: 247/255, alpha: 1.0)
        case "teal":            return UIColor(red: 20/255, green: 184/255, blue: 166/255, alpha: 1.0)
        case "pink":            return UIColor(red: 236/255, green: 72/255, blue: 153/255, alpha: 1.0)
        case "cyan":            return UIColor(red: 6/255, green: 182/255, blue: 212/255, alpha: 1.0)
        case "indigo":          return UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1.0)
        case "amber":           return UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1.0)
        case "gray", "grey":    return UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1.0)
        default: break
        }

        var hex = lower.replacingOccurrences(of: "#", with: "")
        if hex.count == 3 {
            let r = hex[hex.startIndex]
            let g = hex[hex.index(hex.startIndex, offsetBy: 1)]
            let b = hex[hex.index(hex.startIndex, offsetBy: 2)]
            hex = "\(r)\(r)\(g)\(g)\(b)\(b)"
        }

        if hex.count == 6 || hex.count == 8 {
            var rgb: UInt64 = 0
            if Scanner(string: hex).scanHexInt64(&rgb) {
                if hex.count == 6 {
                    let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                    let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                    let b = CGFloat(rgb & 0x0000FF) / 255.0
                    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
                } else {
                    let r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                    let g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                    let b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                    let a = CGFloat(rgb & 0x000000FF) / 255.0
                    return UIColor(red: r, green: g, blue: b, alpha: a)
                }
            }
        }

        return nil
    }

    private func colorByType(_ eventType: String) -> UIColor {
        let type = eventType.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if type.contains("PTM") || type.contains("PARENT") || type.contains("MEETING") {
            return UIColor(red: 234/255, green: 179/255, blue: 8/255, alpha: 1.0)
        } else if type.contains("FEE") {
            return UIColor(red: 234/255, green: 179/255, blue: 8/255, alpha: 1.0)
        } else if type.contains("EXAM") || type.contains("TEST") {
            return UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
        } else if type.contains("HOLIDAY") || type.contains("VACATION") {
            return UIColor(red: 249/255, green: 115/255, blue: 22/255, alpha: 1.0)
        } else if type.contains("EVENT") || type.contains("SPORTS") || type.contains("ANNUAL") {
            return UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)
        } else if type.contains("HOMEWORK") {
            return UIColor(red: 168/255, green: 85/255, blue: 247/255, alpha: 1.0)
        } else if type.contains("ASSIGNMENT") {
            return UIColor(red: 20/255, green: 184/255, blue: 166/255, alpha: 1.0)
        } else if type.contains("TRANSPORT") || type.contains("BUS") {
            return UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0)
        }
        return UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0)
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white

        Goodmorningwithstudentnamelabel?.isHidden = false
        calendarView?.isHidden = false
        TodayeventsContainerview?.isHidden = false

        setupCalendar()
        setupForcedLayout()
        setupCustomHeader()
        updateMonthLabel()
        setupTodayFocusCards()
        updateGreetingLabel()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        updateGreetingLabel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        calendarView?.isHidden = false
        TodayeventsContainerview?.isHidden = false

        // Label ni front ki teesukuni calendar overlap avoid
        if let label = Goodmorningwithstudentnamelabel {
            contentView.bringSubviewToFront(label)
        }
    }

    // MARK: - Force Layout
    private func setupForcedLayout() {
        guard !didSetupLayout else { return }
        didSetupLayout = true

        guard let calendarView = calendarView,
              let todayContainer = TodayeventsContainerview,
              let greetingLabel = Goodmorningwithstudentnamelabel else {
            print("⚠️ CalenderVCTableViewCell1: outlets missing")
            return
        }

        // Bring label to front BEFORE adding calendar constraints
        contentView.bringSubviewToFront(greetingLabel)

        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        todayContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(calendarView.constraints.filter {
            $0.firstAttribute == .height || $0.secondAttribute == .height
        })

        // ⬇️ FIXED: Increased gap from 56 → 120 to fit subtitle text + custom header
        NSLayoutConstraint.activate([
            // Greeting at top
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Calendar with ENOUGH gap for subtitle + custom month header
            calendarView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 120),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            calendarView.heightAnchor.constraint(equalToConstant: 340),

            // Today events container
            todayContainer.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 12),
            todayContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            todayContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            todayContainer.heightAnchor.constraint(equalToConstant: 280),
            todayContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        todayContainer.backgroundColor = .white
        calendarView.backgroundColor = .white

        print("✅ Forced layout applied with proper spacing")
    }

    // MARK: - Configure with API Events
    func configure(with events: [SchoolCalendarEvent]) {
        self.apiEvents = events
        buildEventsByDateCache()

        calendarView?.isHidden = false
        TodayeventsContainerview?.isHidden = false

        // Label ni front ki teesukuni calendar overlap avoid
        if let label = Goodmorningwithstudentnamelabel {
            label.isHidden = false
            contentView.bringSubviewToFront(label)
        }

        calendarView?.reloadData()
        updateTodayFocusCards()
        updateGreetingLabel()
        updateMonthLabel()

        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Greeting
    private func updateGreetingLabel() {
        let studentName = UserManager.shared.resolvedStudentName
        let greeting = greetingForCurrentTime()
        Goodmorningwithstudentnamelabel?.text = "\(greeting), \(studentName)"
        Goodmorningwithstudentnamelabel?.isHidden = false

        // Label ni front ki teesukuni calendar overlap avoid
        if let label = Goodmorningwithstudentnamelabel {
            contentView.bringSubviewToFront(label)
        }
        print("👋 Greeting set → \(greeting), \(studentName)")
    }

    private func greetingForCurrentTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default:      return "Good Evening"
        }
    }

    // MARK: - Build Date → Events Cache
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

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFormatter.date(from: trimmed) {
            return apiDateFormatter.string(from: d)
        }
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let d = isoFormatter.date(from: trimmed) {
            return apiDateFormatter.string(from: d)
        }

        let otherFormatter = DateFormatter()
        otherFormatter.locale = Locale(identifier: "en_US_POSIX")
        otherFormatter.timeZone = TimeZone.current
        for fmt in ["yyyy-MM-dd", "dd-MM-yyyy", "yyyy/MM/dd", "dd/MM/yyyy"] {
            otherFormatter.dateFormat = fmt
            if let d = otherFormatter.date(from: trimmed) {
                return apiDateFormatter.string(from: d)
            }
        }

        return trimmed
    }

    private func buildEventsByDateCache() {
        var map: [String: [SchoolCalendarEvent]] = [:]
        for event in apiEvents {
            if let rawDate = event.eventDate, let key = dateKey(from: rawDate) {
                map[key, default: []].append(event)
            }
        }
        eventsByDate = map
        print("📅 CalendarCell: cache \(map.count) dates from \(apiEvents.count) events: \(map.keys)")
    }

    private func events(for date: Date) -> [SchoolCalendarEvent] {
        let key = apiDateFormatter.string(from: date)
        return eventsByDate[key] ?? []
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        guard let calendarView = calendarView else { return false }
        return Calendar.current.isDate(
            date,
            equalTo: calendarView.currentPage,
            toGranularity: .month
        )
    }

    // MARK: - Calendar Setup
    private func setupCalendar() {
        guard let calendarView = calendarView else { return }

        calendarView.delegate = self
        calendarView.dataSource = self

        calendarView.scope = .month
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
        calendarView.headerHeight = 0
        calendarView.appearance.headerMinimumDissolvedAlpha = 0

        calendarView.layer.cornerRadius = 16
        calendarView.clipsToBounds = true
        calendarView.backgroundColor = .white
        calendarView.isHidden = false

        calendarView.appearance.weekdayTextColor = .darkGray
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 13, weight: .medium)

        calendarView.appearance.titleDefaultColor = .black
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.titlePlaceholderColor = .lightGray
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

        calendarView.appearance.todayColor = .clear
        calendarView.appearance.titleTodayColor = .black
        calendarView.appearance.selectionColor = .clear
        calendarView.appearance.titleSelectionColor = .black
        calendarView.appearance.borderRadius = 0.4

        calendarView.register(
            MultiColorCalendarCell.self,
            forCellReuseIdentifier: "MultiColorCalendarCell"
        )

        calendarView.rowHeight = 48
    }

    // MARK: - Custom Header
    private func setupCustomHeader() {
        guard let calendarView = calendarView else { return }

        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.backgroundColor = .clear
        contentView.addSubview(headerContainerView)

        monthYearLabel.translatesAutoresizingMaskIntoConstraints = false
        monthYearLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        monthYearLabel.textColor = .black
        monthYearLabel.textAlignment = .left
        headerContainerView.addSubview(monthYearLabel)

        previousButton.translatesAutoresizingMaskIntoConstraints = false
        let previousImage = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        )
        previousButton.setImage(previousImage, for: .normal)
        previousButton.tintColor = .darkGray
        previousButton.backgroundColor = UIColor(red: 245/255, green: 236/255, blue: 153/255, alpha: 1.0)
        previousButton.layer.cornerRadius = 16
        previousButton.clipsToBounds = true
        previousButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        headerContainerView.addSubview(previousButton)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        let nextImage = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        )
        nextButton.setImage(nextImage, for: .normal)
        nextButton.tintColor = .darkGray
        nextButton.backgroundColor = UIColor(red: 245/255, green: 236/255, blue: 153/255, alpha: 1.0)
        nextButton.layer.cornerRadius = 16
        nextButton.clipsToBounds = true
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        headerContainerView.addSubview(nextButton)

        NSLayoutConstraint.activate([
            headerContainerView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 4),
            headerContainerView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -4),
            headerContainerView.bottomAnchor.constraint(equalTo: calendarView.topAnchor, constant: -4),
            headerContainerView.heightAnchor.constraint(equalToConstant: 40),

            monthYearLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            monthYearLabel.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),

            nextButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 32),
            nextButton.heightAnchor.constraint(equalToConstant: 32),

            previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -8),
            previousButton.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            previousButton.widthAnchor.constraint(equalToConstant: 32),
            previousButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    @objc private func previousMonthTapped() { moveMonth(by: -1) }
    @objc private func nextMonthTapped()     { moveMonth(by: 1) }

    private func moveMonth(by value: Int) {
        guard let calendarView = calendarView else { return }
        let currentPage = calendarView.currentPage
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentPage) {
            calendarView.setCurrentPage(newDate, animated: true)
            updateMonthLabel()
        }
    }

    private func updateMonthLabel() {
        guard let calendarView = calendarView else { return }
        monthYearLabel.text = dateFormatter.string(from: calendarView.currentPage)
    }

    // MARK: - Today Focus Cards
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
    private var todaySectionTitle: UILabel?

    private func updateTodayFocusCards() {
        let today = Date()
        let todayEvents = events(for: today)

        if todayEvents.count >= 1 {
            let ev1 = todayEvents[0]
            todayTitle1?.text    = ev1.title ?? "Event"
            todaySubtitle1?.text = ev1.timeRangeDisplayText
            todayIcon1?.image    = icon(for: ev1.eventType ?? "")
            let c1 = color(for: ev1)
            todayIcon1?.tintColor = c1
            todayIconCircle1?.backgroundColor = c1.withAlphaComponent(0.15)
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
            todayTitle2?.text    = ev2.title ?? "Event"
            todaySubtitle2?.text = ev2.timeRangeDisplayText
            todayIcon2?.image    = icon(for: ev2.eventType ?? "")
            let c2 = color(for: ev2)
            todayIcon2?.tintColor = c2
            todayIconCircle2?.backgroundColor = c2.withAlphaComponent(0.15)
            todayCard2?.isHidden = false
        } else {
            todayCard2?.isHidden = true
        }
    }

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
        guard let todayContainer = TodayeventsContainerview else { return }

        todayContainer.subviews.forEach { $0.removeFromSuperview() }
        todayContainer.isHidden = false
        todayContainer.backgroundColor = .white

        let cardBackgroundColor = UIColor(red: 241/255, green: 236/255, blue: 204/255, alpha: 1.0)

        let sectionTitle = UILabel()
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        sectionTitle.text = "Today's Focus"
        sectionTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        sectionTitle.textColor = .black
        todayContainer.addSubview(sectionTitle)
        self.todaySectionTitle = sectionTitle

        let card1 = UIView()
        card1.translatesAutoresizingMaskIntoConstraints = false
        card1.backgroundColor = cardBackgroundColor
        card1.layer.cornerRadius = 18
        self.todayCard1 = card1

        let iconCircle1 = UIView()
        iconCircle1.translatesAutoresizingMaskIntoConstraints = false
        iconCircle1.backgroundColor = UIColor(red: 244/255, green: 213/255, blue: 213/255, alpha: 1.0)
        iconCircle1.layer.cornerRadius = 22
        self.todayIconCircle1 = iconCircle1

        let icon1 = UIImageView()
        icon1.translatesAutoresizingMaskIntoConstraints = false
        icon1.image = UIImage(systemName: "doc.text")
        icon1.tintColor = UIColor.brown
        icon1.contentMode = .scaleAspectFit
        self.todayIcon1 = icon1

        let title1 = UILabel()
        title1.translatesAutoresizingMaskIntoConstraints = false
        title1.text = "No events today"
        title1.font = .systemFont(ofSize: 18, weight: .medium)
        title1.textColor = .black
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
        iconCircle2.backgroundColor = UIColor(red: 203/255, green: 231/255, blue: 255/255, alpha: 1.0)
        iconCircle2.layer.cornerRadius = 22
        self.todayIconCircle2 = iconCircle2

        let icon2 = UIImageView()
        icon2.translatesAutoresizingMaskIntoConstraints = false
        icon2.image = UIImage(systemName: "person.3.fill")
        icon2.tintColor = .systemTeal
        icon2.contentMode = .scaleAspectFit
        self.todayIcon2 = icon2

        let title2 = UILabel()
        title2.translatesAutoresizingMaskIntoConstraints = false
        title2.text = "PTA Meeting"
        title2.font = .systemFont(ofSize: 18, weight: .medium)
        title2.textColor = .black
        self.todayTitle2 = title2

        let subtitle2 = UILabel()
        subtitle2.translatesAutoresizingMaskIntoConstraints = false
        subtitle2.text = "03:30 PM • Main Hall"
        subtitle2.textColor = .darkGray
        subtitle2.font = .systemFont(ofSize: 14)
        self.todaySubtitle2 = subtitle2

        todayContainer.addSubview(card1)
        todayContainer.addSubview(card2)

        card1.addSubview(iconCircle1)
        iconCircle1.addSubview(icon1)
        card1.addSubview(title1)
        card1.addSubview(subtitle1)

        card2.addSubview(iconCircle2)
        iconCircle2.addSubview(icon2)
        card2.addSubview(title2)
        card2.addSubview(subtitle2)

        NSLayoutConstraint.activate([
            sectionTitle.leadingAnchor.constraint(equalTo: todayContainer.leadingAnchor, constant: 18),
            sectionTitle.trailingAnchor.constraint(equalTo: todayContainer.trailingAnchor, constant: -18),
            sectionTitle.topAnchor.constraint(equalTo: todayContainer.topAnchor, constant: 8),

            card1.leadingAnchor.constraint(equalTo: todayContainer.leadingAnchor, constant: 18),
            card1.trailingAnchor.constraint(equalTo: todayContainer.trailingAnchor, constant: -18),
            card1.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 12),
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
            icon1.widthAnchor.constraint(equalToConstant: 22),
            icon1.heightAnchor.constraint(equalToConstant: 22),

            title1.leadingAnchor.constraint(equalTo: iconCircle1.trailingAnchor, constant: 16),
            title1.trailingAnchor.constraint(equalTo: card1.trailingAnchor, constant: -12),
            title1.topAnchor.constraint(equalTo: card1.topAnchor, constant: 20),

            subtitle1.leadingAnchor.constraint(equalTo: title1.leadingAnchor),
            subtitle1.trailingAnchor.constraint(equalTo: title1.trailingAnchor),
            subtitle1.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 4),

            iconCircle2.leadingAnchor.constraint(equalTo: card2.leadingAnchor, constant: 16),
            iconCircle2.centerYAnchor.constraint(equalTo: card2.centerYAnchor),
            iconCircle2.widthAnchor.constraint(equalToConstant: 44),
            iconCircle2.heightAnchor.constraint(equalToConstant: 44),

            icon2.centerXAnchor.constraint(equalTo: iconCircle2.centerXAnchor),
            icon2.centerYAnchor.constraint(equalTo: iconCircle2.centerYAnchor),
            icon2.widthAnchor.constraint(equalToConstant: 22),
            icon2.heightAnchor.constraint(equalToConstant: 22),

            title2.leadingAnchor.constraint(equalTo: iconCircle2.trailingAnchor, constant: 16),
            title2.trailingAnchor.constraint(equalTo: card2.trailingAnchor, constant: -12),
            title2.topAnchor.constraint(equalTo: card2.topAnchor, constant: 20),

            subtitle2.leadingAnchor.constraint(equalTo: title2.leadingAnchor),
            subtitle2.trailingAnchor.constraint(equalTo: title2.trailingAnchor),
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
        calendar.reloadData()
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {
        guard isCurrentMonth(date) else { return .lightGray }
        let dayEvents = events(for: date)
        if !dayEvents.isEmpty { return .white }
        return .black
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

        let dayEvents = events(for: date)
        let isCurrent = (position == .current) || isCurrentMonth(date)

        if !dayEvents.isEmpty && isCurrent {
            let colors = dayEvents.map { color(for: $0) }
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
        let dayEvents = events(for: date)
        onDateSelected?(date, dayEvents)

        if dayEvents.count > 1 {
            onMultipleEventsTapped?()
        } else if let event = dayEvents.first {
            let type = (event.eventType ?? "").uppercased()
            if type.contains("FEE") {
                onFeeEventDateTapped?()
            } else if type.contains("PTM") || type.contains("MEETING") {
                onPTMeetingTapped?()
            } else if type.contains("EXAM") || type.contains("TEST") {
                onExamEventTapped?()
            } else if type.contains("HOLIDAY") || type.contains("VACATION") {
                onHolidayTapped?()
            } else if type.contains("HOMEWORK") {
                onHomeworkTapped?()
            } else if type.contains("ASSIGNMENT") {
                onAssignmentTapped?()
            } else if type.contains("TRANSPORT") || type.contains("BUS") {
                onTransportTapped?()
            } else {
                onEventTapped?()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            calendar.deselect(date)
        }
    }
}
