//
//  CalendarTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

 
import UIKit
import FSCalendar

 class CalendarTableViewCel: FSCalendarCell {

    private let rectLayer = CAShapeLayer()
    private let halfLayer = CAShapeLayer()
    private let highlightCornerRadius: CGFloat = 8
    private let horizontalInset: CGFloat = 2
    private let verticalInset: CGFloat = 2

    private let monthLabel = UILabel()
    private let dateLabel = UILabel()
    private let weekdayLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.isHidden = true
        subtitleLabel?.isHidden = true
        setupLayers()
        setupLabels()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel.isHidden = true
        subtitleLabel?.isHidden = true
        setupLayers()
        setupLabels()
    }

    private func setupLayers() {
        contentView.layer.cornerRadius = highlightCornerRadius
        contentView.clipsToBounds = true

        rectLayer.fillColor = UIColor.clear.cgColor
        contentView.layer.insertSublayer(rectLayer, at: 0)

        halfLayer.fillColor = UIColor.clear.cgColor
        contentView.layer.insertSublayer(halfLayer, above: rectLayer)
    }

    private func setupLabels() {
        monthLabel.font = .lexend(.semiBold, size: 10)
        dateLabel.font = .lexend(.semiBold, size: 12)
        weekdayLabel.font = .lexend(.semiBold, size: 10)

        [monthLabel, dateLabel, weekdayLabel].forEach {
            $0.textAlignment = .center
            $0.textColor = .label
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.7
        }

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(monthLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(weekdayLabel)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rectLayer.frame = bounds.insetBy(dx: horizontalInset, dy: verticalInset)
        rectLayer.path = UIBezierPath(roundedRect: rectLayer.bounds, cornerRadius: highlightCornerRadius).cgPath
        halfLayer.frame = rectLayer.frame
    }

    func configure(with date: Date) {
        let formatter = DateFormatter()

        formatter.dateFormat = "MMM"
        monthLabel.text = formatter.string(from: date).uppercased()

        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)

        formatter.dateFormat = "EEE"
        weekdayLabel.text = formatter.string(from: date).uppercased()
    }

    func setFullDayColor(_ color: UIColor) {
        rectLayer.fillColor = color.cgColor
        halfLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        [monthLabel, dateLabel, weekdayLabel].forEach { $0.textColor = .white }
    }

     func setHalfDayColors(topColor: UIColor, bottomColor: UIColor) {
        rectLayer.fillColor = UIColor.clear.cgColor
        halfLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let width = rectLayer.bounds.width
        let height = rectLayer.bounds.height / 2

        let topRect = CGRect(x: 0, y: 0, width: width, height: height)
        let bottomRect = CGRect(x: 0, y: height, width: width, height: height)

        let topLayer = CAShapeLayer()
        topLayer.path = UIBezierPath(roundedRect: topRect,
                                     byRoundingCorners: [.topLeft, .topRight],
                                     cornerRadii: CGSize(width: highlightCornerRadius, height: highlightCornerRadius)).cgPath
        topLayer.fillColor = topColor.cgColor

        let bottomLayer = CAShapeLayer()
        bottomLayer.path = UIBezierPath(roundedRect: bottomRect,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: highlightCornerRadius, height: highlightCornerRadius)).cgPath
        bottomLayer.fillColor = bottomColor.cgColor

        halfLayer.addSublayer(topLayer)
        halfLayer.addSublayer(bottomLayer)
        [monthLabel, dateLabel, weekdayLabel].forEach { $0.textColor = .white }
    }
}

 struct DayAttendanceStats {
    var present: [Int]
    var absent: [Int]
    var half: [Int]
}

 class CalendarTableViewCell: UITableViewCell, FSCalendarDelegate, FSCalendarDataSource {
     var onSelectMonth: ((Date) -> Void)?

    @IBOutlet weak var bgVw: UIView!

    let calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.scope = .month
        cal.firstWeekday = 2
        cal.headerHeight = 0
        cal.placeholderType = .none
        cal.appearance.weekdayTextColor = .clear
        cal.appearance.headerTitleColor = .clear
        cal.appearance.todayColor = .clear
        cal.appearance.titleDefaultColor = .clear
        cal.appearance.titleTodayColor = .clear
        return cal
    }()

    private let prevButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        btn.tintColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var monthlyAttendance: [String: DayAttendanceStats] = [
        "2025-10": DayAttendanceStats(present: [2,4,6,7,8], absent: [1,5], half: [9,10]),
        "2025-11": DayAttendanceStats(present: [1,5,3], absent: [4,5], half: [6])
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
        setupHeader()
        setupShadow()

        DispatchQueue.main.async {
            self.calendar.reloadData()
            self.updateMonthLabel()
        }
    }

    private func setupCalendar() {
        bgVw.addSubview(calendar)
        calendar.delegate = self
        calendar.dataSource = self
        calendar.register(CalendarTableViewCel.self, forCellReuseIdentifier: "attendanceCell")

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: bgVw.topAnchor, constant: 10),
            calendar.leadingAnchor.constraint(equalTo: bgVw.leadingAnchor, constant: 4),
            calendar.trailingAnchor.constraint(equalTo: bgVw.trailingAnchor, constant: -4),
            calendar.bottomAnchor.constraint(equalTo: bgVw.bottomAnchor, constant: -8)
        ])
    }

    private func setupHeader() {
        bgVw.addSubview(prevButton)
        bgVw.addSubview(nextButton)
        bgVw.addSubview(monthLabel)

        prevButton.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)

        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: bgVw.leadingAnchor, constant: 12),
            prevButton.topAnchor.constraint(equalTo: bgVw.topAnchor, constant: 8),
            prevButton.widthAnchor.constraint(equalToConstant: 25),
            prevButton.heightAnchor.constraint(equalToConstant: 25),

            nextButton.trailingAnchor.constraint(equalTo: bgVw.trailingAnchor, constant: -12),
            nextButton.topAnchor.constraint(equalTo: bgVw.topAnchor, constant: 8),
            nextButton.widthAnchor.constraint(equalToConstant: 25),
            nextButton.heightAnchor.constraint(equalToConstant: 25),

            monthLabel.centerXAnchor.constraint(equalTo: bgVw.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: prevButton.centerYAnchor)
        ])
    }

    private func setupShadow() {
        bgVw.backgroundColor = .white
        bgVw.layer.cornerRadius = 10
        bgVw.layer.shadowColor = UIColor.black.cgColor
        bgVw.layer.shadowOpacity = 0.1
        bgVw.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgVw.layer.shadowRadius = 4
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgVw.layer.shadowPath = UIBezierPath(roundedRect: bgVw.bounds, cornerRadius: 10).cgPath
    }

    @objc private func prevMonth() { moveMonth(isNext: false) }
    @objc private func nextMonth() { moveMonth(isNext: true) }

    private func moveMonth(isNext: Bool) {
        let currentPage = calendar.currentPage
        var components = DateComponents()
        components.month = isNext ? 1 : -1
        if let newPage = Calendar.current.date(byAdding: components, to: currentPage) {
            calendar.setCurrentPage(newPage, animated: true)
            updateMonthLabel()
            self.onSelectMonth?(newPage)
        }
    }

    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: calendar.currentPage)
    }

    // MARK: - FSCalendar Delegate + DataSource
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "attendanceCell", for: date, at: position) as! CalendarTableViewCel
        cell.configure(with: date)

        let day = Calendar.current.component(.day, from: date)
        let weekday = Calendar.current.component(.weekday, from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthKey = formatter.string(from: date)

        // Apply attendance colors
        if let attendance = monthlyAttendance[monthKey] {
            if attendance.present.contains(day) {
                cell.setFullDayColor(UIColor(hex: "#0FAF13")!)
            } else if attendance.absent.contains(day) {
                cell.setFullDayColor(UIColor(hex: "#FF0019")!)
            } else if attendance.half.contains(day) {
                cell.setHalfDayColors(topColor: UIColor(hex: "#0FAF13")!, bottomColor: UIColor(hex: "#FF0019")!)
            } else if weekday == 1 {
                cell.setFullDayColor(UIColor(hex: "#0B569A")!)
            } else {
                cell.setFullDayColor(UIColor(hex: "#CBE5FD")!)
            }
        } else {
            if weekday == 1 {
                cell.setFullDayColor(UIColor(hex: "#0B569A")!)
            } else {
                cell.setFullDayColor(UIColor(hex: "#CBE5FD")!)
            }
        }
        return cell
    }
}

