//
//  ATDNCdashboardUITableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/08/26.
//

import UIKit
import FSCalendar

class ATDNCdashboardUITableViewCell1: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var Collectionview3: UICollectionView!
    @IBOutlet weak var Collectionview2: UICollectionView!
    @IBOutlet weak var Collectionview: UICollectionView!

    // MARK: - Layout Constants

    private let cardSpacing: CGFloat = 8
    private let sideInset: CGFloat = 16
    private let cardHeight: CGFloat = 60

    private let calendarHeight: CGFloat = 426
    private let calendarTopSpace: CGFloat = 16

    // MARK: - Quick Navigation Constants

    private let quickNavCellWidth: CGFloat = 80
    private let quickNavCellHeight: CGFloat = 92
    private let quickNavSpacing: CGFloat = 12
    private let quickNavSectionHeight: CGFloat = 92
    private let quickNavTopSpace: CGFloat = 16
    private let quickNavTitleHeight: CGFloat = 24
    private let quickNavTitleTopSpace: CGFloat = 16

    // MARK: - Recent Attendance Constants

    private let recentAttendanceRowHeight: CGFloat = 52
    private let recentAttendanceTitleTopSpace: CGFloat = 16
    private let recentAttendanceTitleHeight: CGFloat = 24
    private let recentAttendanceTopSpace: CGFloat = 12

    // MARK: - Attendance Status

    enum AttendanceStatus {

        case present
        case absent
        case leave
        case late

        var fillColor: UIColor {

            switch self {

            case .present:
                return UIColor(
                    red: 220 / 255,
                    green: 245 / 255,
                    blue: 230 / 255,
                    alpha: 1
                )

            case .absent:
                return UIColor(
                    red: 252 / 255,
                    green: 226 / 255,
                    blue: 228 / 255,
                    alpha: 1
                )

            case .leave:
                return UIColor(
                    red: 222 / 255,
                    green: 235 / 255,
                    blue: 253 / 255,
                    alpha: 1
                )

            case .late:
                return UIColor(
                    red: 253 / 255,
                    green: 235 / 255,
                    blue: 214 / 255,
                    alpha: 1
                )
            }
        }

        var dotColor: UIColor {

            switch self {

            case .present:
                return UIColor(
                    red: 34 / 255,
                    green: 160 / 255,
                    blue: 82 / 255,
                    alpha: 1
                )

            case .absent:
                return UIColor(
                    red: 225 / 255,
                    green: 70 / 255,
                    blue: 80 / 255,
                    alpha: 1
                )

            case .leave:
                return UIColor(
                    red: 50 / 255,
                    green: 120 / 255,
                    blue: 220 / 255,
                    alpha: 1
                )

            case .late:
                return UIColor(
                    red: 235 / 255,
                    green: 120 / 255,
                    blue: 35 / 255,
                    alpha: 1
                )
            }
        }

        var displayText: String {

            switch self {

            case .present:
                return "Present"

            case .absent:
                return "Absent"

            case .leave:
                return "Leave"

            case .late:
                return "Late"
            }
        }
    }

    // MARK: - Demo Attendance Data

    private var attendanceData: [String: AttendanceStatus] = [

        "2026-05-05": .present,
        "2026-05-07": .present,
        "2026-05-12": .present,
        "2026-05-13": .absent,
        "2026-05-15": .present,
        "2026-05-19": .present,
        "2026-05-20": .late,
        "2026-05-21": .leave,
        "2026-05-26": .present,
        "2026-05-27": .late
    ]

    // MARK: - Date Formatters

    private let dateFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale =
            Locale(identifier: "en_US_POSIX")

        formatter.calendar =
            Calendar(identifier: .gregorian)

        formatter.timeZone =
            TimeZone(secondsFromGMT: 0)

        formatter.dateFormat =
            "yyyy-MM-dd"

        return formatter
    }()

    private lazy var calendarMonthFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale =
            Locale(identifier: "en_US_POSIX")

        formatter.dateFormat =
            "MMMM yyyy"

        return formatter
    }()

    // MARK: - Recent Attendance Model

    struct RecentAttendance {

        let dateText: String
        let status: AttendanceStatus
    }

    // MARK: - Demo Recent Attendance Data

    private var recentAttendance: [RecentAttendance] = [

        RecentAttendance(
            dateText: "20 May 2026",
            status: .present
        ),

        RecentAttendance(
            dateText: "19 May 2026",
            status: .present
        ),

        RecentAttendance(
            dateText: "18 May 2026",
            status: .absent
        )
    ]

    // MARK: - Calendar Views

    private var calendarContainer: UIView!
    private var calendar: FSCalendar!

    private var calendarTitleLabel: UILabel!
    private var calendarMonthLabel: UILabel!
    private var previousMonthButton: UIButton!
    private var nextMonthButton: UIButton!
    private var calendarDividerView: UIView!
    private var calendarLegendStackView: UIStackView!

    // MARK: - Quick Navigation Views

    private var quickNavTitleLabel: UILabel!

    // MARK: - Recent Attendance Views

    private var recentAttendanceTitleLabel: UILabel!
    private var recentAttendanceContainer: UIView!
    private var recentAttendanceHeightConstraint: NSLayoutConstraint!

    // MARK: - Attendance Stat Model

    private struct AttendanceStat {

        let title: String
        var value: String
        let backgroundColor: UIColor
        let borderColor: UIColor
        let textColor: UIColor
    }

    // MARK: - Quick Navigation Model

    private struct QuickNavItem {

        let title: String
        let imageName: String
        let backgroundColor: UIColor
    }

    // MARK: - Attendance Stats

    private var stats: [AttendanceStat] = [

        AttendanceStat(
            title: "Present",
            value: "18",
            backgroundColor: UIColor(
                red: 232 / 255,
                green: 247 / 255,
                blue: 237 / 255,
                alpha: 1
            ),
            borderColor: UIColor(
                red: 167 / 255,
                green: 220 / 255,
                blue: 184 / 255,
                alpha: 1
            ),
            textColor: UIColor(
                red: 34 / 255,
                green: 160 / 255,
                blue: 82 / 255,
                alpha: 1
            )
        ),

        AttendanceStat(
            title: "Absent",
            value: "5",
            backgroundColor: UIColor(
                red: 253 / 255,
                green: 235 / 255,
                blue: 236 / 255,
                alpha: 1
            ),
            borderColor: UIColor(
                red: 244 / 255,
                green: 184 / 255,
                blue: 188 / 255,
                alpha: 1
            ),
            textColor: UIColor(
                red: 225 / 255,
                green: 70 / 255,
                blue: 80 / 255,
                alpha: 1
            )
        ),

        AttendanceStat(
            title: "Leave",
            value: "2",
            backgroundColor: UIColor(
                red: 232 / 255,
                green: 241 / 255,
                blue: 253 / 255,
                alpha: 1
            ),
            borderColor: UIColor(
                red: 170 / 255,
                green: 205 / 255,
                blue: 245 / 255,
                alpha: 1
            ),
            textColor: UIColor(
                red: 50 / 255,
                green: 120 / 255,
                blue: 220 / 255,
                alpha: 1
            )
        ),

        AttendanceStat(
            title: "Att. %",
            value: "72%",
            backgroundColor: UIColor(
                red: 254 / 255,
                green: 242 / 255,
                blue: 230 / 255,
                alpha: 1
            ),
            borderColor: UIColor(
                red: 248 / 255,
                green: 200 / 255,
                blue: 160 / 255,
                alpha: 1
            ),
            textColor: UIColor(
                red: 235 / 255,
                green: 120 / 255,
                blue: 35 / 255,
                alpha: 1
            )
        )
    ]

    // MARK: - Quick Navigation Items

    private var quickNavItems: [QuickNavItem] = [

        QuickNavItem(
            title: "My Child\nAttendance",
            imageName: "Icon 51",
            backgroundColor: UIColor(
                red: 254 / 255,
                green: 236 / 255,
                blue: 220 / 255,
                alpha: 1
            )
        ),

        QuickNavItem(
            title: "Attendance\nReport",
            imageName: "reporticon",
            backgroundColor: UIColor(
                red: 226 / 255,
                green: 236 / 255,
                blue: 253 / 255,
                alpha: 1
            )
        ),

        QuickNavItem(
            title: "Leave\nStatus",
            imageName: "icon 52",
            backgroundColor: UIColor(
                red: 226 / 255,
                green: 236 / 255,
                blue: 253 / 255,
                alpha: 1
            )
        ),

        QuickNavItem(
            title: "Request\nCorrection",
            imageName: "editicon",
            backgroundColor: UIColor(
                red: 220 / 255,
                green: 245 / 255,
                blue: 230 / 255,
                alpha: 1
            )
        )
    ]

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupCollectionView()
        setupCalendar()
        setupQuickNavigation()
        setupRecentAttendance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        Collectionview?.collectionViewLayout.invalidateLayout()
        Collectionview2?.collectionViewLayout.invalidateLayout()
        Collectionview3?.collectionViewLayout.invalidateLayout()

        calendarContainer?.layer.shadowPath =
            UIBezierPath(
                roundedRect: calendarContainer.bounds,
                cornerRadius: 12
            ).cgPath
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

    // MARK: - Top Collection View Setup

    private func setupCollectionView() {

        guard let collectionView =
                Collectionview else {
            return
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.bounces = false

        collectionView.register(
            UINib(
                nibName: "ATDNCattendanceCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier:
                "ATDNCattendanceCollectionViewCell"
        )

        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = cardSpacing
        layout.minimumInteritemSpacing = cardSpacing

        layout.sectionInset =
            UIEdgeInsets(
                top: 0,
                left: sideInset,
                bottom: 0,
                right: sideInset
            )

        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }

    // MARK: - Calendar Setup

    private func setupCalendar() {

        setupCalendarContainer()
        setupCalendarHeader()
        setupFSCalendar()
        setupCalendarDivider()
        setupCalendarLegend()
        activateCalendarConstraints()
        showInitialCalendarMonth()
    }

    private func setupCalendarContainer() {

        calendarContainer = UIView()
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.backgroundColor = .white
        calendarContainer.layer.cornerRadius = 12
        calendarContainer.layer.borderWidth = 1

        calendarContainer.layer.borderColor =
            UIColor(
                red: 229 / 255,
                green: 231 / 255,
                blue: 235 / 255,
                alpha: 1
            ).cgColor

        calendarContainer.layer.shadowColor =
            UIColor.black.cgColor

        calendarContainer.layer.shadowOpacity = 0.06

        calendarContainer.layer.shadowOffset =
            CGSize(
                width: 0,
                height: 2
            )

        calendarContainer.layer.shadowRadius = 4
        calendarContainer.layer.masksToBounds = false

        contentView.addSubview(
            calendarContainer
        )
    }

    private func setupCalendarHeader() {

        calendarTitleLabel = UILabel()
        calendarTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarTitleLabel.text = "Attendance Summary"
        calendarTitleLabel.numberOfLines = 1

        calendarTitleLabel.font =
            UIFont.systemFont(
                ofSize: 15,
                weight: .semibold
            )

        calendarTitleLabel.textColor =
            UIColor(
                red: 31 / 255,
                green: 41 / 255,
                blue: 55 / 255,
                alpha: 1
            )

        calendarTitleLabel.adjustsFontSizeToFitWidth = true
        calendarTitleLabel.minimumScaleFactor = 0.75

        calendarTitleLabel.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )

        calendarContainer.addSubview(
            calendarTitleLabel
        )

        previousMonthButton = UIButton(type: .system)

        previousMonthButton.translatesAutoresizingMaskIntoConstraints =
            false

        previousMonthButton.tintColor =
            UIColor(
                red: 75 / 255,
                green: 85 / 255,
                blue: 99 / 255,
                alpha: 1
            )

        previousMonthButton.setImage(
            UIImage(
                systemName: "chevron.left"
            ),
            for: .normal
        )

        previousMonthButton.addTarget(
            self,
            action: #selector(previousMonthTapped),
            for: .touchUpInside
        )

        previousMonthButton.accessibilityLabel =
            "Previous month"

        calendarContainer.addSubview(
            previousMonthButton
        )

        calendarMonthLabel = UILabel()

        calendarMonthLabel.translatesAutoresizingMaskIntoConstraints =
            false

        calendarMonthLabel.font =
            UIFont.systemFont(
                ofSize: 15,
                weight: .semibold
            )

        calendarMonthLabel.textColor =
            UIColor(
                red: 31 / 255,
                green: 41 / 255,
                blue: 55 / 255,
                alpha: 1
            )

        calendarMonthLabel.textAlignment = .center
        calendarMonthLabel.adjustsFontSizeToFitWidth = true
        calendarMonthLabel.minimumScaleFactor = 0.75

        calendarContainer.addSubview(
            calendarMonthLabel
        )

        nextMonthButton = UIButton(type: .system)

        nextMonthButton.translatesAutoresizingMaskIntoConstraints =
            false

        nextMonthButton.tintColor =
            UIColor(
                red: 75 / 255,
                green: 85 / 255,
                blue: 99 / 255,
                alpha: 1
            )

        nextMonthButton.setImage(
            UIImage(
                systemName: "chevron.right"
            ),
            for: .normal
        )

        nextMonthButton.addTarget(
            self,
            action: #selector(nextMonthTapped),
            for: .touchUpInside
        )

        nextMonthButton.accessibilityLabel =
            "Next month"

        calendarContainer.addSubview(
            nextMonthButton
        )
    }

    private func setupFSCalendar() {

        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false

        calendar.delegate = self
        calendar.dataSource = self

        calendar.backgroundColor = .white
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.placeholderType = .none

        // Custom header is used.
        calendar.headerHeight = 0
        calendar.weekdayHeight = 34

        calendar.firstWeekday = 1

        calendar.appearance.caseOptions = [
            .weekdayUsesSingleUpperCase
        ]

        calendar.appearance.weekdayTextColor =
            UIColor(
                red: 142 / 255,
                green: 142 / 255,
                blue: 147 / 255,
                alpha: 1
            )

        calendar.appearance.weekdayFont =
            UIFont.systemFont(
                ofSize: 13,
                weight: .semibold
            )

        calendar.appearance.titleDefaultColor =
            UIColor(
                red: 17 / 255,
                green: 24 / 255,
                blue: 39 / 255,
                alpha: 1
            )

        calendar.appearance.titleFont =
            UIFont.systemFont(
                ofSize: 14,
                weight: .medium
            )

        calendar.appearance.todayColor = .clear

        calendar.appearance.titleTodayColor =
            UIColor(
                red: 17 / 255,
                green: 24 / 255,
                blue: 39 / 255,
                alpha: 1
            )

        calendar.appearance.selectionColor = .clear

        calendar.appearance.titleSelectionColor =
            UIColor(
                red: 17 / 255,
                green: 24 / 255,
                blue: 39 / 255,
                alpha: 1
            )

        // Fully circular attendance backgrounds.
        calendar.appearance.borderRadius = 1.0

        calendar.appearance.eventOffset =
            CGPoint(
                x: 0,
                y: 2
            )

        calendar.appearance.eventDefaultColor =
            .clear

        calendar.appearance.eventSelectionColor =
            .clear

        calendarContainer.addSubview(
            calendar
        )
    }

    private func setupCalendarDivider() {

        calendarDividerView = UIView()

        calendarDividerView.translatesAutoresizingMaskIntoConstraints =
            false

        calendarDividerView.backgroundColor =
            UIColor(
                red: 229 / 255,
                green: 231 / 255,
                blue: 235 / 255,
                alpha: 1
            )

        calendarContainer.addSubview(
            calendarDividerView
        )
    }

    private func setupCalendarLegend() {

        let presentItem =
            makeCalendarLegendItem(
                title: "Present",
                color: AttendanceStatus.present.dotColor
            )

        let absentItem =
            makeCalendarLegendItem(
                title: "Absent",
                color: AttendanceStatus.absent.dotColor
            )

        let leaveItem =
            makeCalendarLegendItem(
                title: "Leave",
                color: AttendanceStatus.leave.dotColor
            )

        let lateItem =
            makeCalendarLegendItem(
                title: "Late",
                color: AttendanceStatus.late.dotColor
            )

        calendarLegendStackView =
            UIStackView(
                arrangedSubviews: [
                    presentItem,
                    absentItem,
                    leaveItem,
                    lateItem
                ]
            )

        calendarLegendStackView.translatesAutoresizingMaskIntoConstraints =
            false

        calendarLegendStackView.axis = .horizontal
        calendarLegendStackView.alignment = .center
        calendarLegendStackView.distribution = .equalSpacing
        calendarLegendStackView.spacing = 6

        calendarContainer.addSubview(
            calendarLegendStackView
        )
    }

    private func makeCalendarLegendItem(
        title: String,
        color: UIColor
    ) -> UIView {

        let dotView = UIView()

        dotView.translatesAutoresizingMaskIntoConstraints =
            false

        dotView.backgroundColor = color
        dotView.layer.cornerRadius = 5
        dotView.clipsToBounds = true

        NSLayoutConstraint.activate([

            dotView.widthAnchor.constraint(
                equalToConstant: 10
            ),

            dotView.heightAnchor.constraint(
                equalToConstant: 10
            )
        ])

        let titleLabel = UILabel()

        titleLabel.text = title
        titleLabel.numberOfLines = 1

        titleLabel.font =
            UIFont.systemFont(
                ofSize: 12,
                weight: .regular
            )

        titleLabel.textColor =
            UIColor(
                red: 75 / 255,
                green: 85 / 255,
                blue: 99 / 255,
                alpha: 1
            )

        let stackView =
            UIStackView(
                arrangedSubviews: [
                    dotView,
                    titleLabel
                ]
            )

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5

        return stackView
    }

    private func activateCalendarConstraints() {

        NSLayoutConstraint.activate([

            // Calendar container
            calendarContainer.topAnchor.constraint(
                equalTo: Collectionview.bottomAnchor,
                constant: calendarTopSpace
            ),

            calendarContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: sideInset
            ),

            calendarContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -sideInset
            ),

            calendarContainer.heightAnchor.constraint(
                equalToConstant: calendarHeight
            ),

            // Header title
            calendarTitleLabel.topAnchor.constraint(
                equalTo: calendarContainer.topAnchor,
                constant: 18
            ),

            calendarTitleLabel.leadingAnchor.constraint(
                equalTo: calendarContainer.leadingAnchor,
                constant: 16
            ),

            calendarTitleLabel.heightAnchor.constraint(
                equalToConstant: 24
            ),

            calendarTitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo:
                    previousMonthButton.leadingAnchor,
                constant: -4
            ),

            // Previous month button
            previousMonthButton.centerYAnchor.constraint(
                equalTo:
                    calendarTitleLabel.centerYAnchor
            ),

            previousMonthButton.widthAnchor.constraint(
                equalToConstant: 26
            ),

            previousMonthButton.heightAnchor.constraint(
                equalToConstant: 32
            ),

            // Month label
            calendarMonthLabel.centerYAnchor.constraint(
                equalTo:
                    calendarTitleLabel.centerYAnchor
            ),

            calendarMonthLabel.leadingAnchor.constraint(
                equalTo:
                    previousMonthButton.trailingAnchor,
                constant: 0
            ),

            calendarMonthLabel.widthAnchor.constraint(
                equalToConstant: 75
            ),

            // Next button
            nextMonthButton.centerYAnchor.constraint(
                equalTo:
                    calendarTitleLabel.centerYAnchor
            ),

            nextMonthButton.leadingAnchor.constraint(
                equalTo:
                    calendarMonthLabel.trailingAnchor,
                constant: 0
            ),

            nextMonthButton.trailingAnchor.constraint(
                equalTo:
                    calendarContainer.trailingAnchor,
                constant: -10
            ),

            nextMonthButton.widthAnchor.constraint(
                equalToConstant: 26
            ),

            nextMonthButton.heightAnchor.constraint(
                equalToConstant: 32
            ),

            // FSCalendar
            calendar.topAnchor.constraint(
                equalTo:
                    calendarTitleLabel.bottomAnchor,
                constant: 12
            ),

            calendar.leadingAnchor.constraint(
                equalTo:
                    calendarContainer.leadingAnchor,
                constant: 12
            ),

            calendar.trailingAnchor.constraint(
                equalTo:
                    calendarContainer.trailingAnchor,
                constant: -12
            ),

            calendar.bottomAnchor.constraint(
                equalTo:
                    calendarDividerView.topAnchor,
                constant: -8
            ),

            // Divider
            calendarDividerView.leadingAnchor.constraint(
                equalTo:
                    calendarContainer.leadingAnchor,
                constant: 16
            ),

            calendarDividerView.trailingAnchor.constraint(
                equalTo:
                    calendarContainer.trailingAnchor,
                constant: -16
            ),

            calendarDividerView.bottomAnchor.constraint(
                equalTo:
                    calendarContainer.bottomAnchor,
                constant: -56
            ),

            calendarDividerView.heightAnchor.constraint(
                equalToConstant: 1
            ),

            // Legend
            calendarLegendStackView.topAnchor.constraint(
                equalTo:
                    calendarDividerView.bottomAnchor,
                constant: 10
            ),

            calendarLegendStackView.leadingAnchor.constraint(
                equalTo:
                    calendarContainer.leadingAnchor,
                constant: 20
            ),

            calendarLegendStackView.trailingAnchor.constraint(
                equalTo:
                    calendarContainer.trailingAnchor,
                constant: -20
            ),

            calendarLegendStackView.bottomAnchor.constraint(
                equalTo:
                    calendarContainer.bottomAnchor,
                constant: -10
            )
        ])
    }

    private func showInitialCalendarMonth() {

        guard let initialDate =
                dateFormatter.date(
                    from: "2026-05-01"
                ) else {

            updateCalendarHeader()
            return
        }

        calendar.setCurrentPage(
            initialDate,
            animated: false
        )

        updateCalendarHeader()
    }

    // MARK: - Calendar Navigation

    @objc
    private func previousMonthTapped() {

        guard let previousMonth =
                Calendar.current.date(
                    byAdding: .month,
                    value: -1,
                    to: calendar.currentPage
                ) else {
            return
        }

        calendar.setCurrentPage(
            previousMonth,
            animated: true
        )
    }

    @objc
    private func nextMonthTapped() {

        guard let nextMonth =
                Calendar.current.date(
                    byAdding: .month,
                    value: 1,
                    to: calendar.currentPage
                ) else {
            return
        }

        calendar.setCurrentPage(
            nextMonth,
            animated: true
        )
    }

    private func updateCalendarHeader() {

        guard calendar != nil else {
            return
        }

        let monthText =
            calendarMonthFormatter.string(
                from: calendar.currentPage
            )

        calendarTitleLabel.text =
            "Attendance Summary (\(monthText))"

        calendarMonthLabel.text =
            monthText
    }

    // MARK: - Quick Navigation Setup

    private func setupQuickNavigation() {

        guard let collectionView =
                Collectionview2 else {
            return
        }

        quickNavTitleLabel = UILabel()

        quickNavTitleLabel.translatesAutoresizingMaskIntoConstraints =
            false

        quickNavTitleLabel.text =
            "Quick Navigation"

        quickNavTitleLabel.font =
            UIFont.systemFont(
                ofSize: 18,
                weight: .semibold
            )

        quickNavTitleLabel.textColor =
            .black

        contentView.addSubview(
            quickNavTitleLabel
        )

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.bounces = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
            UINib(
                nibName: "ATDNCmultitypeattendanceCLVCLL",
                bundle: nil
            ),
            forCellWithReuseIdentifier:
                "ATDNCmultitypeattendanceCLVCLL"
        )

        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = quickNavSpacing
        layout.minimumInteritemSpacing = quickNavSpacing

        layout.sectionInset =
            UIEdgeInsets(
                top: 0,
                left: sideInset,
                bottom: 0,
                right: sideInset
            )

        collectionView.collectionViewLayout =
            layout

        if collectionView.superview == nil {
            contentView.addSubview(
                collectionView
            )
        }

        NSLayoutConstraint.activate([

            quickNavTitleLabel.topAnchor.constraint(
                equalTo:
                    calendarContainer.bottomAnchor,
                constant: quickNavTitleTopSpace
            ),

            quickNavTitleLabel.leadingAnchor.constraint(
                equalTo:
                    contentView.leadingAnchor,
                constant: sideInset
            ),

            quickNavTitleLabel.trailingAnchor.constraint(
                equalTo:
                    contentView.trailingAnchor,
                constant: -sideInset
            ),

            quickNavTitleLabel.heightAnchor.constraint(
                equalToConstant: quickNavTitleHeight
            ),

            collectionView.topAnchor.constraint(
                equalTo:
                    quickNavTitleLabel.bottomAnchor,
                constant: quickNavTopSpace
            ),

            collectionView.leadingAnchor.constraint(
                equalTo:
                    contentView.leadingAnchor
            ),

            collectionView.trailingAnchor.constraint(
                equalTo:
                    contentView.trailingAnchor
            ),

            collectionView.heightAnchor.constraint(
                equalToConstant:
                    quickNavSectionHeight
            )
        ])

        collectionView.reloadData()
    }

    // MARK: - Recent Attendance Setup

    private func setupRecentAttendance() {

        guard let collectionView =
                Collectionview3 else {
            return
        }

        recentAttendanceTitleLabel = UILabel()

        recentAttendanceTitleLabel.translatesAutoresizingMaskIntoConstraints =
            false

        recentAttendanceTitleLabel.text =
            "Recent Attendance"

        recentAttendanceTitleLabel.font =
            UIFont.systemFont(
                ofSize: 18,
                weight: .semibold
            )

        recentAttendanceTitleLabel.textColor =
            .black

        contentView.addSubview(
            recentAttendanceTitleLabel
        )

        recentAttendanceContainer = UIView()

        recentAttendanceContainer.translatesAutoresizingMaskIntoConstraints =
            false

        recentAttendanceContainer.backgroundColor =
            .white

        recentAttendanceContainer.layer.cornerRadius =
            12

        recentAttendanceContainer.layer.borderWidth =
            1

        recentAttendanceContainer.layer.borderColor =
            UIColor(
                red: 229 / 255,
                green: 231 / 255,
                blue: 235 / 255,
                alpha: 1
            ).cgColor

        recentAttendanceContainer.layer.masksToBounds =
            true

        contentView.addSubview(
            recentAttendanceContainer
        )

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.bounces = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
            UINib(
                nibName: "ATDNCattendanceCLVCLL",
                bundle: nil
            ),
            forCellWithReuseIdentifier:
                "ATDNCattendanceCLVCLL"
        )

        let layout =
            UICollectionViewFlowLayout()

        layout.scrollDirection =
            .vertical

        layout.minimumLineSpacing =
            0

        layout.minimumInteritemSpacing =
            0

        layout.sectionInset =
            .zero

        collectionView.collectionViewLayout =
            layout

        recentAttendanceContainer.addSubview(
            collectionView
        )

        recentAttendanceHeightConstraint =
            recentAttendanceContainer.heightAnchor.constraint(
                equalToConstant:
                    CGFloat(recentAttendance.count)
                    * recentAttendanceRowHeight
            )

        NSLayoutConstraint.activate([

            recentAttendanceTitleLabel.topAnchor.constraint(
                equalTo:
                    Collectionview2.bottomAnchor,
                constant:
                    recentAttendanceTitleTopSpace
            ),

            recentAttendanceTitleLabel.leadingAnchor.constraint(
                equalTo:
                    contentView.leadingAnchor,
                constant: sideInset
            ),

            recentAttendanceTitleLabel.trailingAnchor.constraint(
                equalTo:
                    contentView.trailingAnchor,
                constant: -sideInset
            ),

            recentAttendanceTitleLabel.heightAnchor.constraint(
                equalToConstant:
                    recentAttendanceTitleHeight
            ),

            recentAttendanceContainer.topAnchor.constraint(
                equalTo:
                    recentAttendanceTitleLabel.bottomAnchor,
                constant:
                    recentAttendanceTopSpace
            ),

            recentAttendanceContainer.leadingAnchor.constraint(
                equalTo:
                    contentView.leadingAnchor,
                constant: sideInset
            ),

            recentAttendanceContainer.trailingAnchor.constraint(
                equalTo:
                    contentView.trailingAnchor,
                constant: -sideInset
            ),

            recentAttendanceHeightConstraint,

            collectionView.topAnchor.constraint(
                equalTo:
                    recentAttendanceContainer.topAnchor
            ),

            collectionView.leadingAnchor.constraint(
                equalTo:
                    recentAttendanceContainer.leadingAnchor
            ),

            collectionView.trailingAnchor.constraint(
                equalTo:
                    recentAttendanceContainer.trailingAnchor
            ),

            collectionView.bottomAnchor.constraint(
                equalTo:
                    recentAttendanceContainer.bottomAnchor
            )
        ])

        collectionView.reloadData()
    }

    // MARK: - Recent Attendance Height

    private func updateRecentAttendanceHeight() {

        let height =
            CGFloat(recentAttendance.count)
            * recentAttendanceRowHeight

        recentAttendanceHeightConstraint.constant =
            height

        contentView.layoutIfNeeded()
    }

    // MARK: - Attendance Date Helper

    private func status(
        for date: Date
    ) -> AttendanceStatus? {

        let key =
            dateFormatter.string(
                from: date
            )

        return attendanceData[key]
    }

    // MARK: - Configure Attendance Stats

    func configure(
        present: Int,
        absent: Int,
        leave: Int,
        attendancePercent: Int
    ) {

        stats[0].value =
            "\(present)"

        stats[1].value =
            "\(absent)"

        stats[2].value =
            "\(leave)"

        stats[3].value =
            "\(attendancePercent)%"

        Collectionview?.reloadData()
    }

    // MARK: - Configure Calendar

    func configureCalendar(
        with data: [String: AttendanceStatus]
    ) {

        attendanceData = data
        calendar?.reloadData()
    }

    // MARK: - Configure Recent Attendance

    func configureRecentAttendance(
        with items: [RecentAttendance]
    ) {

        recentAttendance = items

        Collectionview3?.reloadData()

        updateRecentAttendanceHeight()

        if let tableView =
            findParentTableView() {

            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    private func findParentTableView() -> UITableView? {

        var parentView: UIView? =
            superview

        while let currentView =
                parentView {

            if let tableView =
                currentView as? UITableView {

                return tableView
            }

            parentView =
                currentView.superview
        }

        return nil
    }

    // MARK: - Total Content Height

    func totalContentHeight() -> CGFloat {

        let recentHeight =
            CGFloat(recentAttendance.count)
            * recentAttendanceRowHeight

        let total: CGFloat =
            cardHeight
            + calendarTopSpace
            + calendarHeight
            + quickNavTitleTopSpace
            + quickNavTitleHeight
            + quickNavTopSpace
            + quickNavSectionHeight
            + recentAttendanceTitleTopSpace
            + recentAttendanceTitleHeight
            + recentAttendanceTopSpace
            + recentHeight
            + 16

        return total
    }
}

// MARK: - UICollectionViewDataSource

extension ATDNCdashboardUITableViewCell1:
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        if collectionView == Collectionview2 {
            return quickNavItems.count
        }

        if collectionView == Collectionview3 {
            return recentAttendance.count
        }

        return stats.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        // MARK: Quick Navigation Cell

        if collectionView == Collectionview2 {

            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        "ATDNCmultitypeattendanceCLVCLL",
                    for: indexPath
                ) as! ATDNCmultitypeattendanceCLVCLL

            let item =
                quickNavItems[indexPath.item]

            cell.Backgroundview.backgroundColor =
                item.backgroundColor

            cell.Backgroundview.layer.cornerRadius =
                16

            cell.Backgroundview.layer.masksToBounds =
                true

            cell.Imageview.image =
                UIImage(
                    named: item.imageName
                )

            cell.Imageview.contentMode =
                .scaleAspectFit

            cell.TitleLbl.text =
                item.title

            cell.TitleLbl.numberOfLines =
                2

            cell.TitleLbl.textAlignment =
                .center

            cell.TitleLbl.font =
                UIFont.systemFont(
                    ofSize: 12,
                    weight: .medium
                )

            cell.TitleLbl.textColor =
                .black

            return cell
        }

        // MARK: Recent Attendance Cell

        if collectionView == Collectionview3 {

            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        "ATDNCattendanceCLVCLL",
                    for: indexPath
                ) as! ATDNCattendanceCLVCLL

            let item =
                recentAttendance[indexPath.item]

            cell.DateLbl.text =
                item.dateText

            cell.DateLbl.font =
                UIFont.systemFont(
                    ofSize: 15,
                    weight: .medium
                )

            cell.DateLbl.textColor =
                .black

            let statusColor =
                item.status.dotColor

            let statusText =
                item.status.displayText

            let attributedText =
                NSMutableAttributedString()

            let dotAttachment =
                NSTextAttachment()

            let dotSize: CGFloat =
                8

            let dotImage =
                UIGraphicsImageRenderer(
                    size: CGSize(
                        width: dotSize,
                        height: dotSize
                    )
                ).image { _ in

                    statusColor.setFill()

                    UIBezierPath(
                        ovalIn: CGRect(
                            x: 0,
                            y: 0,
                            width: dotSize,
                            height: dotSize
                        )
                    ).fill()
                }

            dotAttachment.image =
                dotImage

            dotAttachment.bounds =
                CGRect(
                    x: 0,
                    y: -1,
                    width: dotSize,
                    height: dotSize
                )

            attributedText.append(
                NSAttributedString(
                    attachment: dotAttachment
                )
            )

            attributedText.append(
                NSAttributedString(
                    string: "  \(statusText)",
                    attributes: [
                        .foregroundColor: statusColor,
                        .font: UIFont.systemFont(
                            ofSize: 15,
                            weight: .medium
                        )
                    ]
                )
            )

            cell.AttendancestatusLbl.attributedText =
                attributedText

            cell.AttendancestatusLbl.textAlignment =
                .right

            cell.Backgroundview.backgroundColor =
                .white

            cell.Backgroundview.layer.sublayers?
                .removeAll(
                    where: {
                        $0.name == "bottomSeparator"
                    }
                )

            if indexPath.item <
                recentAttendance.count - 1 {

                let separator =
                    CALayer()

                separator.name =
                    "bottomSeparator"

                separator.backgroundColor =
                    UIColor(
                        red: 229 / 255,
                        green: 231 / 255,
                        blue: 235 / 255,
                        alpha: 1
                    ).cgColor

                separator.frame =
                    CGRect(
                        x: 16,
                        y:
                            recentAttendanceRowHeight
                            - 1,
                        width:
                            collectionView.bounds.width
                            - 32,
                        height: 1
                    )

                cell.Backgroundview.layer.addSublayer(
                    separator
                )
            }

            return cell
        }

        // MARK: Attendance Stat Cell

        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier:
                    "ATDNCattendanceCollectionViewCell",
                for: indexPath
            ) as! ATDNCattendanceCollectionViewCell

        let stat =
            stats[indexPath.item]

        cell.configure(
            title: stat.title,
            value: stat.value,
            backgroundColor:
                stat.backgroundColor,
            borderColor:
                stat.borderColor,
            textColor:
                stat.textColor
        )

        return cell
    }

    // MARK: - Cell Size

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        if collectionView == Collectionview2 {

            return CGSize(
                width: quickNavCellWidth,
                height: quickNavCellHeight
            )
        }

        if collectionView == Collectionview3 {

            return CGSize(
                width: collectionView.bounds.width,
                height: recentAttendanceRowHeight
            )
        }

        let cardCount =
            CGFloat(stats.count)

        let totalSpacing =
            cardSpacing
            * (cardCount - 1)

        let totalInsets =
            sideInset * 2

        let availableWidth =
            collectionView.bounds.width
            - totalSpacing
            - totalInsets

        let cardWidth =
            floor(
                availableWidth
                / cardCount
            )

        return CGSize(
            width: cardWidth,
            height: cardHeight
        )
    }
}

// MARK: - FSCalendar Delegate, DataSource and Appearance

extension ATDNCdashboardUITableViewCell1:
    FSCalendarDelegate,
    FSCalendarDataSource,
    FSCalendarDelegateAppearance {

    func calendarCurrentPageDidChange(
        _ calendar: FSCalendar
    ) {

        updateCalendarHeader()
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        fillDefaultColorFor date: Date
    ) -> UIColor? {

        return status(
            for: date
        )?.fillColor
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {

        guard let attendanceStatus =
                status(
                    for: date
                ) else {

            return UIColor(
                red: 17 / 255,
                green: 24 / 255,
                blue: 39 / 255,
                alpha: 1
            )
        }

        return attendanceStatus.dotColor
    }

    func calendar(
        _ calendar: FSCalendar,
        numberOfEventsFor date: Date
    ) -> Int {

        return status(for: date) == nil
            ? 0
            : 1
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        eventDefaultColorsFor date: Date
    ) -> [UIColor]? {

        guard let attendanceStatus =
                status(
                    for: date
                ) else {

            return nil
        }

        return [
            attendanceStatus.dotColor
        ]
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        eventSelectionColorsFor date: Date
    ) -> [UIColor]? {

        guard let attendanceStatus =
                status(
                    for: date
                ) else {

            return nil
        }

        return [
            attendanceStatus.dotColor
        ]
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        borderRadiusFor date: Date
    ) -> CGFloat {

        return 1
    }

    func calendar(
        _ calendar: FSCalendar,
        shouldSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) -> Bool {

        return false
    }
}
