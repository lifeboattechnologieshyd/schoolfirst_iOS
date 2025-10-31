//
//  CalendarTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit
import FSCalendar

 class AttendanceCalendarCell: FSCalendarCell {
    
    private let rectLayer = CAShapeLayer()
    private let halfLayer = CAShapeLayer()
    private let highlightCornerRadius: CGFloat = 6
    private let horizontalInset: CGFloat = 8
    private let verticalInset: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    private func setupLayers() {
        rectLayer.fillColor = UIColor.clear.cgColor
        layer.insertSublayer(rectLayer, at: 0)
        
        halfLayer.fillColor = UIColor.clear.cgColor
        layer.insertSublayer(halfLayer, above: rectLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rectLayer.frame = bounds.insetBy(dx: horizontalInset, dy: verticalInset)
        halfLayer.frame = bounds.insetBy(dx: horizontalInset, dy: verticalInset / 2)
        titleLabel.textAlignment = .center
        titleLabel.frame = bounds
    }
    
    func setFullDayColor(_ color: UIColor) {
        rectLayer.path = UIBezierPath(roundedRect: rectLayer.bounds, cornerRadius: highlightCornerRadius).cgPath
        rectLayer.fillColor = color.cgColor
        halfLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        titleLabel.textColor = .white
    }
    
    func setHalfDayColors(topColor: UIColor, bottomColor: UIColor) {
        rectLayer.fillColor = UIColor.clear.cgColor
        halfLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = rectLayer.bounds.width
        let height = rectLayer.bounds.height / 2
        
        let topRect = CGRect(x: 0, y: 0, width: width, height: height)
        let topLayer = CAShapeLayer()
        topLayer.path = UIBezierPath(roundedRect: topRect,
                                     byRoundingCorners: [.topLeft, .topRight],
                                     cornerRadii: CGSize(width: highlightCornerRadius, height: highlightCornerRadius)).cgPath
        topLayer.fillColor = topColor.cgColor
        
        let bottomRect = CGRect(x: 0, y: height, width: width, height: height)
        let bottomLayer = CAShapeLayer()
        bottomLayer.path = UIBezierPath(roundedRect: bottomRect,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: highlightCornerRadius, height: highlightCornerRadius)).cgPath
        bottomLayer.fillColor = bottomColor.cgColor
        
        halfLayer.addSublayer(topLayer)
        halfLayer.addSublayer(bottomLayer)
        titleLabel.textColor = .white
    }
}

 struct Attendance {
    var present: [Int]
    var absent: [Int]
    var half: [Int]
}

 class CalendarTableViewCell: UITableViewCell, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var bgVw: UIView!
    
    let calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.scope = .month
        cal.firstWeekday = 2
        cal.clipsToBounds = true
        cal.appearance.titleTodayColor = .label
        cal.appearance.todayColor = .clear
        cal.headerHeight = 0
        cal.placeholderType = .none
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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Attendance per Month
    var monthlyAttendance: [String: Attendance] = [
        "2025-10": Attendance(present: [1,2,3,4,6,7,8,9,10,13,14,15,16,17],
                              absent: [1,3,8,11],
                              half: [18,22]),
        "2025-11": Attendance(present: [2,4,5], absent: [1,3], half: [10,15])
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
        setupHeaderButtons()
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
        calendar.register(AttendanceCalendarCell.self, forCellReuseIdentifier: "attendanceCell")
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: bgVw.topAnchor, constant: 40),
            calendar.leadingAnchor.constraint(equalTo: bgVw.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: bgVw.trailingAnchor),
            calendar.bottomAnchor.constraint(equalTo: bgVw.bottomAnchor)
        ])
    }
    
    private func setupHeaderButtons() {
        bgVw.addSubview(prevButton)
        bgVw.addSubview(nextButton)
        bgVw.addSubview(monthLabel)
        
        prevButton.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: bgVw.leadingAnchor, constant: 12),
            prevButton.topAnchor.constraint(equalTo: bgVw.topAnchor, constant: 4),
            prevButton.widthAnchor.constraint(equalToConstant: 30),
            prevButton.heightAnchor.constraint(equalToConstant: 30),
            
            nextButton.trailingAnchor.constraint(equalTo: bgVw.trailingAnchor, constant: -12),
            nextButton.topAnchor.constraint(equalTo: bgVw.topAnchor, constant: 4),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
            
            monthLabel.centerXAnchor.constraint(equalTo: bgVw.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: prevButton.centerYAnchor)
        ])
    }
    
    private func setupShadow() {
        bgVw.backgroundColor = .white
        bgVw.layer.cornerRadius = 12
        bgVw.layer.masksToBounds = false
        bgVw.layer.shadowColor = UIColor.black.cgColor
        bgVw.layer.shadowOpacity = 0.15
        bgVw.layer.shadowOffset = CGSize(width: 0, height: 3)
        bgVw.layer.shadowRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgVw.layer.shadowPath = UIBezierPath(roundedRect: bgVw.bounds, cornerRadius: 12).cgPath
    }
    
    @objc private func prevMonth() { moveCurrentPage(isNext: false) }
    @objc private func nextMonth() { moveCurrentPage(isNext: true) }
    
    private func moveCurrentPage(isNext: Bool) {
        let currentPage = calendar.currentPage
        var dateComponents = DateComponents()
        dateComponents.month = isNext ? 1 : -1
        if let newPage = Calendar.current.date(byAdding: dateComponents, to: currentPage) {
            calendar.setCurrentPage(newPage, animated: true)
            updateMonthLabel()
        }
    }
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: calendar.currentPage)
    }
    
    // MARK: FSCalendar DataSource
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int { 0 }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "attendanceCell", for: date, at: position) as! AttendanceCalendarCell
        
        let calendarSys = Calendar.current
        let day = calendarSys.component(.day, from: date)
        let weekday = calendarSys.component(.weekday, from: date) // 1 = Sunday
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let key = formatter.string(from: date) // e.g., "2025-10"
        
        cell.setFullDayColor(.clear)
        cell.titleLabel.textColor = .label
        
        if let attendance = monthlyAttendance[key] {
            if attendance.present.contains(day) {
                cell.setFullDayColor(.systemGreen)
            } else if attendance.absent.contains(day) {
                cell.setFullDayColor(.systemRed)
            } else if attendance.half.contains(day) {
                cell.setHalfDayColors(topColor: .systemGreen, bottomColor: .systemRed)
            } else if weekday == 1 {
                cell.setFullDayColor(.systemPurple)
            } else {
                cell.setFullDayColor(.systemTeal) // Not posted
            }
        } else {
            // No data for this month
            if weekday == 1 {
                cell.setFullDayColor(.systemPurple)
            } else {
                cell.setFullDayColor(.systemTeal)
            }
        }
        
        return cell
    }
}

