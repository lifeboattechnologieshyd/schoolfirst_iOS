//
//  ATNDmychiledattendanceTBLVCll.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/08/26.
//

import UIKit
import FSCalendar

class ATNDmychiledattendanceTBLVCll: UITableViewCell {

    // MARK: - Existing Outlet

    @IBOutlet weak var CollectionView: UICollectionView!

    // MARK: - Attendance Status

    private enum AttendanceStatus {
        case present
        case absent
        case today
        case late
    }

    // MARK: - Calendar Views

    private let calendarContainerView: UIView = {

        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(
            red: 0.88,
            green: 0.89,
            blue: 0.91,
            alpha: 1
        ).cgColor

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false

        return view
    }()

    private let monthTitleLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(
            red: 0.10,
            green: 0.11,
            blue: 0.14,
            alpha: 1
        )

        label.font = UIFont.systemFont(
            ofSize: 18,
            weight: .semibold
        )

        label.textAlignment = .left

        return label
    }()

    private let previousMonthButton: UIButton = {

        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemGray

        button.setImage(
            UIImage(systemName: "chevron.left"),
            for: .normal
        )

        return button
    }()

    private let nextMonthButton: UIButton = {

        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemGray

        button.setImage(
            UIImage(systemName: "chevron.right"),
            for: .normal
        )

        return button
    }()

    private let calendarView: FSCalendar = {

        let calendar = FSCalendar()

        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .clear

        return calendar
    }()

    private let dividerView: UIView = {

        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(
            red: 0.85,
            green: 0.87,
            blue: 0.90,
            alpha: 1
        )

        return view
    }()

    // MARK: - Calendar Data

    private var attendanceStatus: [Date: AttendanceStatus] = [:]

    private lazy var monthFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM yyyy"

        return formatter
    }()

    private lazy var sampleDateFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupCalendarContainer()
        setupCalendar()
        setupAttendanceData()
        showInitialMonth()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        calendarContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: calendarContainerView.bounds,
            cornerRadius: 12
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        showInitialMonth()
    }

    override func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {
        super.setSelected(
            selected,
            animated: animated
        )
    }

    // MARK: - Calendar Container Setup

    private func setupCalendarContainer() {

        contentView.addSubview(calendarContainerView)

        calendarContainerView.addSubview(monthTitleLabel)
        calendarContainerView.addSubview(previousMonthButton)
        calendarContainerView.addSubview(nextMonthButton)
        calendarContainerView.addSubview(calendarView)
        calendarContainerView.addSubview(dividerView)

        previousMonthButton.addTarget(
            self,
            action: #selector(previousMonthTapped),
            for: .touchUpInside
        )

        nextMonthButton.addTarget(
            self,
            action: #selector(nextMonthTapped),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([

            // Calendar card dimensions
            calendarContainerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 176
            ),

            calendarContainerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),

            calendarContainerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            calendarContainerView.heightAnchor.constraint(
                equalToConstant: 358
            ),

            // Month title
            monthTitleLabel.topAnchor.constraint(
                equalTo: calendarContainerView.topAnchor,
                constant: 14
            ),

            monthTitleLabel.leadingAnchor.constraint(
                equalTo: calendarContainerView.leadingAnchor,
                constant: 16
            ),

            monthTitleLabel.heightAnchor.constraint(
                equalToConstant: 30
            ),

            // Previous month button
            previousMonthButton.centerYAnchor.constraint(
                equalTo: monthTitleLabel.centerYAnchor
            ),

            previousMonthButton.widthAnchor.constraint(
                equalToConstant: 32
            ),

            previousMonthButton.heightAnchor.constraint(
                equalToConstant: 32
            ),

            // Next month button
            nextMonthButton.centerYAnchor.constraint(
                equalTo: monthTitleLabel.centerYAnchor
            ),

            nextMonthButton.trailingAnchor.constraint(
                equalTo: calendarContainerView.trailingAnchor,
                constant: -10
            ),

            nextMonthButton.widthAnchor.constraint(
                equalToConstant: 32
            ),

            nextMonthButton.heightAnchor.constraint(
                equalToConstant: 32
            ),

            previousMonthButton.trailingAnchor.constraint(
                equalTo: nextMonthButton.leadingAnchor,
                constant: -2
            ),

            // FSCalendar
            calendarView.topAnchor.constraint(
                equalTo: monthTitleLabel.bottomAnchor,
                constant: 2
            ),

            calendarView.leadingAnchor.constraint(
                equalTo: calendarContainerView.leadingAnchor,
                constant: 10
            ),

            calendarView.trailingAnchor.constraint(
                equalTo: calendarContainerView.trailingAnchor,
                constant: -10
            ),

            calendarView.bottomAnchor.constraint(
                equalTo: dividerView.topAnchor,
                constant: -8
            ),

            // Divider
            dividerView.leadingAnchor.constraint(
                equalTo: calendarContainerView.leadingAnchor,
                constant: 16
            ),

            dividerView.trailingAnchor.constraint(
                equalTo: calendarContainerView.trailingAnchor,
                constant: -16
            ),

            dividerView.bottomAnchor.constraint(
                equalTo: calendarContainerView.bottomAnchor,
                constant: -56
            ),

            dividerView.heightAnchor.constraint(
                equalToConstant: 1
            )
        ])

        setupLegend()
    }

    // MARK: - FSCalendar Setup

    private func setupCalendar() {

        calendarView.delegate = self
        calendarView.dataSource = self

        calendarView.scope = .month
        calendarView.scrollDirection = .horizontal
        calendarView.placeholderType = .fillHeadTail

        // Custom month header is used above the calendar.
        calendarView.headerHeight = 0
        calendarView.weekdayHeight = 30

        calendarView.firstWeekday = 1
        calendarView.today = nil

        calendarView.appearance.caseOptions = [
            .weekdayUsesSingleUpperCase
        ]

        calendarView.appearance.weekdayTextColor = UIColor(
            red: 0.43,
            green: 0.46,
            blue: 0.52,
            alpha: 1
        )

        calendarView.appearance.weekdayFont = UIFont.systemFont(
            ofSize: 12,
            weight: .medium
        )

        calendarView.appearance.titleFont = UIFont.systemFont(
            ofSize: 13,
            weight: .regular
        )

        calendarView.appearance.titleDefaultColor = UIColor(
            red: 0.20,
            green: 0.22,
            blue: 0.25,
            alpha: 1
        )

        calendarView.appearance.titlePlaceholderColor = UIColor(
            red: 0.76,
            green: 0.77,
            blue: 0.80,
            alpha: 1
        )

        calendarView.appearance.selectionColor = .systemBlue
        calendarView.appearance.titleSelectionColor = .white
        calendarView.appearance.borderRadius = 1.0
    }

    // MARK: - Attendance Data

    private func setupAttendanceData() {

        attendanceStatus.removeAll()

        // Present dates
        addStatus(.present, dateString: "2026-05-05")
        addStatus(.present, dateString: "2026-05-07")
        addStatus(.present, dateString: "2026-05-12")
        addStatus(.present, dateString: "2026-05-15")
        addStatus(.present, dateString: "2026-05-19")

        // Absent dates
        addStatus(.absent, dateString: "2026-05-13")
        addStatus(.absent, dateString: "2026-05-20")

        // Today
        addStatus(.today, dateString: "2026-05-21")

        // Late
        addStatus(.late, dateString: "2026-05-25")

        calendarView.reloadData()
    }

    private func addStatus(
        _ status: AttendanceStatus,
        dateString: String
    ) {

        guard let date = sampleDateFormatter.date(
            from: dateString
        ) else {
            return
        }

        let normalizedDate = Calendar.current.startOfDay(
            for: date
        )

        attendanceStatus[normalizedDate] = status
    }

    private func status(for date: Date) -> AttendanceStatus? {

        let normalizedDate = Calendar.current.startOfDay(
            for: date
        )

        return attendanceStatus[normalizedDate]
    }

    // MARK: - Initial Month

    private func showInitialMonth() {

        guard let date = sampleDateFormatter.date(
            from: "2026-05-01"
        ) else {
            return
        }

        calendarView.setCurrentPage(
            date,
            animated: false
        )

        updateMonthTitle()
    }

    private func updateMonthTitle() {

        monthTitleLabel.text = monthFormatter.string(
            from: calendarView.currentPage
        )
    }

    // MARK: - Calendar Navigation

    @objc
    private func previousMonthTapped() {

        guard let previousMonth = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: calendarView.currentPage
        ) else {
            return
        }

        calendarView.setCurrentPage(
            previousMonth,
            animated: true
        )
    }

    @objc
    private func nextMonthTapped() {

        guard let nextMonth = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: calendarView.currentPage
        ) else {
            return
        }

        calendarView.setCurrentPage(
            nextMonth,
            animated: true
        )
    }

    // MARK: - Legend

    private func setupLegend() {

        let presentLegend = makeLegendItem(
            title: "Present",
            color: attendanceColor(for: .present)
        )

        let absentLegend = makeLegendItem(
            title: "Absent",
            color: attendanceColor(for: .absent)
        )

        let todayLegend = makeLegendItem(
            title: "Today",
            color: attendanceColor(for: .today)
        )

        let lateLegend = makeLegendItem(
            title: "Late",
            color: attendanceColor(for: .late)
        )

        let firstRow = UIStackView(
            arrangedSubviews: [
                presentLegend,
                absentLegend
            ]
        )

        firstRow.translatesAutoresizingMaskIntoConstraints = false
        firstRow.axis = .horizontal
        firstRow.alignment = .center
        firstRow.distribution = .fillEqually
        firstRow.spacing = 12

        let secondRow = UIStackView(
            arrangedSubviews: [
                todayLegend,
                lateLegend
            ]
        )

        secondRow.translatesAutoresizingMaskIntoConstraints = false
        secondRow.axis = .horizontal
        secondRow.alignment = .center
        secondRow.distribution = .fillEqually
        secondRow.spacing = 12

        let legendStack = UIStackView(
            arrangedSubviews: [
                firstRow,
                secondRow
            ]
        )

        legendStack.translatesAutoresizingMaskIntoConstraints = false
        legendStack.axis = .vertical
        legendStack.alignment = .fill
        legendStack.distribution = .fillEqually
        legendStack.spacing = 2

        calendarContainerView.addSubview(legendStack)

        NSLayoutConstraint.activate([

            legendStack.topAnchor.constraint(
                equalTo: dividerView.bottomAnchor,
                constant: 5
            ),

            legendStack.leadingAnchor.constraint(
                equalTo: calendarContainerView.leadingAnchor,
                constant: 16
            ),

            legendStack.trailingAnchor.constraint(
                equalTo: calendarContainerView.trailingAnchor,
                constant: -16
            ),

            legendStack.bottomAnchor.constraint(
                equalTo: calendarContainerView.bottomAnchor,
                constant: -5
            )
        ])
    }

    private func makeLegendItem(
        title: String,
        color: UIColor
    ) -> UIView {

        let dotView = UIView()

        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = color
        dotView.layer.cornerRadius = 6

        NSLayoutConstraint.activate([

            dotView.widthAnchor.constraint(
                equalToConstant: 12
            ),

            dotView.heightAnchor.constraint(
                equalToConstant: 12
            )
        ])

        let titleLabel = UILabel()

        titleLabel.text = title
        titleLabel.textColor = UIColor(
            red: 0.34,
            green: 0.36,
            blue: 0.40,
            alpha: 1
        )

        titleLabel.font = UIFont.systemFont(
            ofSize: 11,
            weight: .regular
        )

        let stackView = UIStackView(
            arrangedSubviews: [
                dotView,
                titleLabel
            ]
        )

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6

        return stackView
    }

    // MARK: - Colors

    private func attendanceColor(
        for status: AttendanceStatus
    ) -> UIColor {

        switch status {

        case .present:
            return UIColor(
                red: 0.00,
                green: 0.31,
                blue: 0.10,
                alpha: 1
            )

        case .absent:
            return UIColor(
                red: 0.80,
                green: 0.09,
                blue: 0.11,
                alpha: 1
            )

        case .today:
            return UIColor(
                red: 0.05,
                green: 0.40,
                blue: 0.75,
                alpha: 1
            )

        case .late:
            return UIColor(
                red: 1.00,
                green: 0.42,
                blue: 0.05,
                alpha: 1
            )
        }
    }
}

// MARK: - FSCalendarDataSource

extension ATNDmychiledattendanceTBLVCll: FSCalendarDataSource {

    func minimumDate(
        for calendar: FSCalendar
    ) -> Date {

        return sampleDateFormatter.date(
            from: "2025-01-01"
        ) ?? Date()
    }

    func maximumDate(
        for calendar: FSCalendar
    ) -> Date {

        return sampleDateFormatter.date(
            from: "2027-12-31"
        ) ?? Date()
    }
}

// MARK: - FSCalendarDelegate

extension ATNDmychiledattendanceTBLVCll: FSCalendarDelegate {

    func calendarCurrentPageDidChange(
        _ calendar: FSCalendar
    ) {
        updateMonthTitle()
    }

    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {

        print(
            "Selected attendance date: \(date)"
        )
    }
}

// MARK: - FSCalendarDelegateAppearance

extension ATNDmychiledattendanceTBLVCll:
    FSCalendarDelegateAppearance {

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        fillDefaultColorFor date: Date
    ) -> UIColor? {

        guard let status = status(for: date) else {
            return .clear
        }

        if status == .today {
            return attendanceColor(
                for: status
            ).withAlphaComponent(0.12)
        }

        return attendanceColor(for: status)
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {

        guard let status = status(for: date) else {
            return nil
        }

        switch status {

        case .present, .absent, .late:
            return .white

        case .today:
            return attendanceColor(for: .today)
        }
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        borderDefaultColorFor date: Date
    ) -> UIColor? {

        guard status(for: date) == .today else {
            return .clear
        }

        return attendanceColor(for: .today)
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        borderRadiusFor date: Date
    ) -> CGFloat {

        return 1.0
    }
}
