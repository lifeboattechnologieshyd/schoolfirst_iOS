//
//  attendancedashboardTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

// MARK: - Delegate to notify VC
protocol AttendancedashboardTBLVCLLDelegate: AnyObject {
    func didTapApplyLeaveButton()
    func didTapPendingLeaveRequests()
}

class attendancedashboardTBLVCLL: UITableViewCell {

    @IBOutlet weak var ViewallButton: UIButton!
    @IBOutlet weak var HistoryButton: UIButton!
    @IBOutlet weak var Attendancestautusbadge: UILabel!
    @IBOutlet weak var RemarksLabel: UILabel!
    @IBOutlet weak var Acadamicyear: UILabel!
    
    @IBOutlet weak var TodaydateLabel: UILabel!
    @IBOutlet weak var AttendancestatusLabel: UILabel!
    @IBOutlet weak var UpcomingrequestLabel: UILabel!
    @IBOutlet weak var NumberofleavependingrequestsLabel: UILabel!
    @IBOutlet weak var TermanddateLabel: UILabel!
    @IBOutlet weak var AcadamicyearLabel: UILabel!
    @IBOutlet weak var Pendingleaverequstscantainerview: UIView!
    @IBOutlet weak var Graphcantainerview: UIView!
    @IBOutlet weak var Gridcantainerview: UIView!
    @IBOutlet weak var Dateandbuttonscantainerview: UIView!

    @IBOutlet weak var Applyleavebutton: UIButton!

    weak var delegate: AttendancedashboardTBLVCLLDelegate?

    // MARK: - UI Elements for Date Container
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let dateLabel = UILabel()
    private let termLabel = UILabel()

    // MARK: - Data Properties
    private var currentDate: Date = Date()

    private let primaryBlue = UIColor(
        red: 0.11,
        green: 0.31,
        blue: 0.61,
        alpha: 1.0
    )

    private let dateTextColor = UIColor(
        red: 0.07,
        green: 0.09,
        blue: 0.15,
        alpha: 1.0
    )

    private let termTextColor = UIColor(
        red: 0.42,
        green: 0.45,
        blue: 0.50,
        alpha: 1.0
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        setupDateContainer()
        setupGridContainer()
        setupGraphContainer()
        updateDateDisplay()

        Applyleavebutton.addTarget(
            self,
            action: #selector(didTapApplyLeave),
            for: .touchUpInside
        )

        Pendingleaverequstscantainerview.isUserInteractionEnabled = true
        let pendingLeaveTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapPendingLeaveRequestsView)
        )
        Pendingleaverequstscantainerview.addGestureRecognizer(
            pendingLeaveTapGesture
        )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure with Attendance API Data
    func configure(with data: FetchStudentAttendanceData?, todayRecord: FetchStudentAttendanceRecord?) {
        
        // TODAY DATE LABEL (e.g., "Monday, 7 Sep")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMM"
        if let dateStr = todayRecord?.attendanceDate,
           let d = Self.apiDateFormatter.date(from: dateStr) {
            TodaydateLabel.text = dateFormatter.string(from: d)
        } else {
            TodaydateLabel.text = dateFormatter.string(from: Date())
        }
        
        // ACADEMIC YEAR (from API)
        if let ayName = data?.academicYear?.name, !ayName.isEmpty {
            AcadamicyearLabel.text = ayName
            Acadamicyear.text = ayName
        } else {
            let cal = Calendar.current
            let y = cal.component(.year, from: Date())
            AcadamicyearLabel.text = "AY \(y)-\((y+1)%100)"
            Acadamicyear.text = "AY \(y)-\((y+1)%100)"
        }
        
        // TERM & DATE LABEL (derived from academic year or static)
        if let start = data?.academicYear?.startDate,
           let end = data?.academicYear?.endDate,
           let s = Self.apiDateFormatter.date(from: start),
           let e = Self.apiDateFormatter.date(from: end) {
            let fmt = DateFormatter()
            fmt.dateFormat = "MMM"
            let sMonth = fmt.string(from: s)
            let eMonth = fmt.string(from: e)
            TermanddateLabel.text = "Term 1 · \(sMonth)-\(eMonth)"
        } else {
            TermanddateLabel.text = "Term 1 · Jun-Oct"
        }
        
        // TODAY ATTENDANCE STATUS (from API record)
        let rawStatus = (todayRecord?.status ?? "PRESENT").uppercased()
        let displayStatus = rawStatus.capitalized
        
        AttendancestatusLabel.text = displayStatus
        Attendancestautusbadge.text = displayStatus
        
        // Badge color styling based on status
        switch rawStatus {
        case "PRESENT":
            Attendancestautusbadge.backgroundColor = UIColor(red: 0.78, green: 0.94, blue: 0.84, alpha: 1.0)
            Attendancestautusbadge.textColor = UIColor(red: 0.04, green: 0.50, blue: 0.28, alpha: 1.0)
            RemarksLabel.text = todayRecord?.remarks?.isEmpty == false ? todayRecord!.remarks! : "Checked in on time"
        case "LATE":
            Attendancestautusbadge.backgroundColor = UIColor(red: 1.0, green: 0.89, blue: 0.55, alpha: 1.0)
            Attendancestautusbadge.textColor = UIColor(red: 0.72, green: 0.29, blue: 0.02, alpha: 1.0)
            RemarksLabel.text = todayRecord?.remarks?.isEmpty == false ? todayRecord!.remarks! : "Late arrival"
        case "ABSENT":
            Attendancestautusbadge.backgroundColor = UIColor(red: 1.0, green: 0.82, blue: 0.84, alpha: 1.0)
            Attendancestautusbadge.textColor = UIColor(red: 0.75, green: 0.08, blue: 0.08, alpha: 1.0)
            RemarksLabel.text = todayRecord?.remarks?.isEmpty == false ? todayRecord!.remarks! : "Absent for today"
        default:
            Attendancestautusbadge.backgroundColor = UIColor(red: 0.86, green: 0.94, blue: 1.0, alpha: 1.0)
            Attendancestautusbadge.textColor = primaryBlue
            RemarksLabel.text = todayRecord?.remarks ?? "No remarks"
        }
        Attendancestautusbadge.layer.cornerRadius = 9
        Attendancestautusbadge.layer.masksToBounds = true
        Attendancestautusbadge.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        Attendancestautusbadge.textAlignment = .center
        
        // SUMMARY VALUES (from API summary)
        if let summary = data?.summary {
            // These could be used to update grid cards in setupGridContainer if needed
            // Keeping existing static cards as-is; only configuring today section per request
        }
    }

    // MARK: - Actions
    @objc private func didTapApplyLeave() {
        delegate?.didTapApplyLeaveButton()
    }

    @objc private func didTapPendingLeaveRequestsView() {
        delegate?.didTapPendingLeaveRequests()
    }

    // MARK: - Setup Top Date Container
    private func setupDateContainer() {
        Dateandbuttonscantainerview.subviews.forEach { $0.removeFromSuperview() }

        Dateandbuttonscantainerview.backgroundColor = .white
        Dateandbuttonscantainerview.layer.cornerRadius = 12
        Dateandbuttonscantainerview.layer.borderWidth = 1
        Dateandbuttonscantainerview.layer.borderColor = UIColor(
            red: 0.88, green: 0.91, blue: 0.94, alpha: 1.0
        ).cgColor
        Dateandbuttonscantainerview.clipsToBounds = true

        let leftArrow = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 16, weight: .semibold
            )
        )

        leftButton.setImage(leftArrow, for: .normal)
        leftButton.tintColor = primaryBlue
        leftButton.addTarget(
            self,
            action: #selector(didTapLeftArrow),
            for: .touchUpInside
        )
        leftButton.translatesAutoresizingMaskIntoConstraints = false

        let rightArrow = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 16, weight: .semibold
            )
        )

        rightButton.setImage(rightArrow, for: .normal)
        rightButton.tintColor = primaryBlue
        rightButton.addTarget(
            self,
            action: #selector(didTapRightArrow),
            for: .touchUpInside
        )
        rightButton.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        dateLabel.textColor = dateTextColor
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        termLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        termLabel.textColor = termTextColor
        termLabel.textAlignment = .center
        termLabel.translatesAutoresizingMaskIntoConstraints = false

        let textStackView = UIStackView(
            arrangedSubviews: [dateLabel, termLabel]
        )

        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .center
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        Dateandbuttonscantainerview.addSubview(leftButton)
        Dateandbuttonscantainerview.addSubview(textStackView)
        Dateandbuttonscantainerview.addSubview(rightButton)

        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(
                equalTo: Dateandbuttonscantainerview.leadingAnchor, constant: 16
            ),
            leftButton.centerYAnchor.constraint(
                equalTo: Dateandbuttonscantainerview.centerYAnchor
            ),
            leftButton.widthAnchor.constraint(equalToConstant: 40),
            leftButton.heightAnchor.constraint(equalToConstant: 40),

            rightButton.trailingAnchor.constraint(
                equalTo: Dateandbuttonscantainerview.trailingAnchor, constant: -16
            ),
            rightButton.centerYAnchor.constraint(
                equalTo: Dateandbuttonscantainerview.centerYAnchor
            ),
            rightButton.widthAnchor.constraint(equalToConstant: 40),
            rightButton.heightAnchor.constraint(equalToConstant: 40),

            textStackView.centerXAnchor.constraint(
                equalTo: Dateandbuttonscantainerview.centerXAnchor
            ),
            textStackView.centerYAnchor.constraint(
                equalTo: Dateandbuttonscantainerview.centerYAnchor
            ),
            textStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leftButton.trailingAnchor, constant: 10
            ),
            textStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: rightButton.leadingAnchor, constant: -10
            ),

            Dateandbuttonscantainerview.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 80
            )
        ])
    }

    // MARK: - Setup Graph Container
    private func setupGraphContainer() {
        Graphcantainerview.subviews.forEach { $0.removeFromSuperview() }

        Graphcantainerview.backgroundColor = .white
        Graphcantainerview.layer.cornerRadius = 12
        Graphcantainerview.layer.borderWidth = 1
        Graphcantainerview.layer.borderColor = UIColor(
            red: 0.88, green: 0.91, blue: 0.94, alpha: 1.0
        ).cgColor

        let graphView = MonthlyTrendGraphView()
        graphView.translatesAutoresizingMaskIntoConstraints = false

        Graphcantainerview.addSubview(graphView)

        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(
                equalTo: Graphcantainerview.topAnchor, constant: 16
            ),
            graphView.leadingAnchor.constraint(
                equalTo: Graphcantainerview.leadingAnchor, constant: 16
            ),
            graphView.trailingAnchor.constraint(
                equalTo: Graphcantainerview.trailingAnchor, constant: -16
            ),
            graphView.bottomAnchor.constraint(
                equalTo: Graphcantainerview.bottomAnchor, constant: -16
            )
        ])
    }

    // MARK: - Setup Grid Container
    private func setupGridContainer() {
        Gridcantainerview.subviews.forEach { $0.removeFromSuperview() }

        let columnStack1 = UIStackView()
        let columnStack2 = UIStackView()

        let mainRowStack = UIStackView(
            arrangedSubviews: [columnStack1, columnStack2]
        )

        columnStack1.axis = .vertical
        columnStack1.spacing = 10
        columnStack1.distribution = .fillEqually

        columnStack2.axis = .vertical
        columnStack2.spacing = 10
        columnStack2.distribution = .fillEqually

        mainRowStack.axis = .horizontal
        mainRowStack.spacing = 10
        mainRowStack.distribution = .fillEqually
        mainRowStack.translatesAutoresizingMaskIntoConstraints = false

        Gridcantainerview.addSubview(mainRowStack)

        NSLayoutConstraint.activate([
            mainRowStack.topAnchor.constraint(
                equalTo: Gridcantainerview.topAnchor, constant: 0
            ),
            mainRowStack.leadingAnchor.constraint(
                equalTo: Gridcantainerview.leadingAnchor, constant: 0
            ),
            mainRowStack.trailingAnchor.constraint(
                equalTo: Gridcantainerview.trailingAnchor, constant: 0
            ),
            mainRowStack.bottomAnchor.constraint(
                equalTo: Gridcantainerview.bottomAnchor, constant: 0
            )
        ])

        let card1 = AttendanceCardView(
            title: "Attendance rate",
            value: "86%",
            valueColor: UIColor(
                red: 0.15, green: 0.39, blue: 0.92, alpha: 1.0
            ),
            subtitle: "Academic year 2026-27"
        )

        let card2 = AttendanceCardView(
            title: "Present days",
            value: "43",
            valueColor: UIColor(
                red: 0.13, green: 0.70, blue: 0.38, alpha: 1.0
            ),
            subtitle: "Out of 50 school days"
        )

        let card3 = AttendanceCardView(
            title: "Absent days",
            value: "5",
            valueColor: UIColor(
                red: 0.92, green: 0.26, blue: 0.21, alpha: 1.0
            ),
            subtitle: "2 consecutive in Aug"
        )

        let card4 = AttendanceCardView(
            title: "Late arrivals",
            value: "2",
            valueColor: UIColor(
                red: 0.96, green: 0.62, blue: 0.04, alpha: 1.0
            ),
            subtitle: "Most recent: 02 Sep"
        )

        columnStack1.addArrangedSubview(card1)
        columnStack1.addArrangedSubview(card3)
        columnStack2.addArrangedSubview(card2)
        columnStack2.addArrangedSubview(card4)
    }

    // MARK: - Button Actions
    @objc private func didTapLeftArrow() {
        if let newDate = Calendar.current.date(
            byAdding: .weekOfYear, value: -1, to: currentDate
        ) {
            currentDate = newDate
            updateDateDisplay()
        }
    }

    @objc private func didTapRightArrow() {
        if let newDate = Calendar.current.date(
            byAdding: .weekOfYear, value: 1, to: currentDate
        ) {
            currentDate = newDate
            updateDateDisplay()
        }
    }

    private func updateDateDisplay() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2

        let startOfWeek = gregorian.date(
            from: gregorian.dateComponents(
                [.yearForWeekOfYear, .weekOfYear], from: currentDate
            )
        ) ?? currentDate

        let endOfWeek = gregorian.date(
            byAdding: .day, value: 4, to: startOfWeek
        ) ?? startOfWeek

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"

        let startDateString = dateFormatter.string(from: startOfWeek)
        let endDateString = dateFormatter.string(from: endOfWeek)

        dateLabel.text = "\(startDateString) – \(endDateString)"

        let termStartDate = Calendar.current.date(
            from: DateComponents(year: 2026, month: 9, day: 1)
        ) ?? Date()

        let weeksPassed = gregorian.dateComponents(
            [.weekOfYear], from: termStartDate, to: startOfWeek
        ).weekOfYear ?? 0

        let currentWeekNumber = max(1, weeksPassed + 1)

        termLabel.text = "Term 1 · Week \(currentWeekNumber)"
    }

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - Graph View (unchanged from working version)
private class MonthlyTrendGraphView: UIView {
    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Monthly trend"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Attendance %"
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

            subtitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let primaryDarkBlue = UIColor(red: 0.11, green: 0.31, blue: 0.61, alpha: 1.0)
        let slateBlue = UIColor(red: 0.49, green: 0.60, blue: 0.73, alpha: 1.0)
        let warningOrange = UIColor(red: 0.91, green: 0.66, blue: 0.25, alpha: 1.0)

        let chartData: [(month: String, val: Int, color: UIColor)] = [
            ("Apr", 92, slateBlue),
            ("May", 88, slateBlue),
            ("Jun", 94, primaryDarkBlue),
            ("Jul", 90, slateBlue),
            ("Aug", 83, warningOrange),
            ("Sep", 86, slateBlue)
        ]

        for data in chartData {
            let barView = SingleBarView(
                month: data.month, value: data.val, color: data.color
            )
            stackView.addArrangedSubview(barView)
        }
    }
}

private class SingleBarView: UIView {
    init(month: String, value: Int, color: UIColor) {
        super.init(frame: .zero)

        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        valueLabel.textColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let barView = UIView()
        barView.backgroundColor = color
        barView.layer.cornerRadius = 6
        barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        barView.translatesAutoresizingMaskIntoConstraints = false

        let monthLabel = UILabel()
        monthLabel.text = month
        monthLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        monthLabel.textColor = UIColor(red: 0.49, green: 0.53, blue: 0.60, alpha: 1.0)
        monthLabel.textAlignment = .center
        monthLabel.translatesAutoresizingMaskIntoConstraints = false

        let barContainer = UIView()
        barContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(monthLabel)
        addSubview(barContainer)
        barContainer.addSubview(barView)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            monthLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            monthLabel.heightAnchor.constraint(equalToConstant: 16),

            barContainer.bottomAnchor.constraint(
                equalTo: monthLabel.topAnchor, constant: -8
            ),
            barContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            barContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            barContainer.topAnchor.constraint(equalTo: topAnchor, constant: 20),

            barView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor),
            barView.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor, constant: 4),
            barView.trailingAnchor.constraint(equalTo: barContainer.trailingAnchor, constant: -4),

            valueLabel.bottomAnchor.constraint(equalTo: barView.topAnchor, constant: -6),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        barView.heightAnchor.constraint(
            equalTo: barContainer.heightAnchor,
            multiplier: min(max(CGFloat(value) / 100.0, 0.0), 1.0)
        ).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class AttendanceCardView: UIView {
    init(title: String, value: String, valueColor: UIColor, subtitle: String) {
        super.init(frame: .zero)
        setupUI(title: title, value: value, valueColor: valueColor, subtitle: subtitle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI(title: String, value: String, valueColor: UIColor, subtitle: String) {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.88, green: 0.91, blue: 0.94, alpha: 1.0).cgColor
        translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = valueColor

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.53, green: 0.56, blue: 0.62, alpha: 1.0)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.8

        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
