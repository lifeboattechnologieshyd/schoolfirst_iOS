//
//  CalendarTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit
import FSCalendar

 struct AttendanceStatus {
    var date: Date
    var status: Status
    
    enum Status {
        case present
        case absent
        case halfDay
    }
}

 class AttendanceCalendarCell: FSCalendarCell {
    
    private let rectLayer = CAShapeLayer()
    private let halfLayer = CAShapeLayer()
    
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
        
        let rect = CGRect(x: 2, y: 2, width: bounds.width - 4, height: bounds.height - 4)
        rectLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 6).cgPath
        
        halfLayer.frame = bounds
        titleLabel.textAlignment = .center
        titleLabel.frame = bounds
    }
    
     func setFullDayColor(_ color: UIColor) {
        rectLayer.fillColor = color.cgColor
        halfLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        titleLabel.textColor = .white
    }
    
     func setHalfDayColors(topColor: UIColor, bottomColor: UIColor) {
        rectLayer.fillColor = UIColor.clear.cgColor
        halfLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = bounds.width - 4
        let height = (bounds.height - 4) / 2
        let y: CGFloat = 2
        
         let topRect = CGRect(x: 2, y: y, width: width, height: height)
        let topLayer = CAShapeLayer()
        topLayer.path = UIBezierPath(roundedRect: topRect, cornerRadius: 4).cgPath
        topLayer.fillColor = topColor.cgColor
        
         let bottomRect = CGRect(x: 2, y: y + height, width: width, height: height)
        let bottomLayer = CAShapeLayer()
        bottomLayer.path = UIBezierPath(roundedRect: bottomRect, cornerRadius: 4).cgPath
        bottomLayer.fillColor = bottomColor.cgColor
        
        halfLayer.addSublayer(topLayer)
        halfLayer.addSublayer(bottomLayer)
        
        titleLabel.textColor = .white
    }
}

 class CalendarTableViewCell: UITableViewCell, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var bgVw: UIView!
    
    let calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.scope = .month
        cal.firstWeekday = 1
        cal.clipsToBounds = true
        cal.appearance.titleTodayColor = .label
        cal.headerHeight = 0 // remove default month header
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
    
    let attendanceDates: [AttendanceStatus] = [
        AttendanceStatus(date: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 24))!, status: .present),
        AttendanceStatus(date: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 25))!, status: .halfDay),
        AttendanceStatus(date: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 27))!, status: .absent)
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
        setupHeaderButtons()
        setupShadow()
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
        
        updateMonthLabel()
    }
    
    private func setupShadow() {
        bgVw.layer.cornerRadius = 12
        bgVw.layer.masksToBounds = false
        bgVw.layer.shadowColor = UIColor.black.cgColor
        bgVw.layer.shadowOpacity = 0.2
        bgVw.layer.shadowOffset = CGSize(width: 0, height: 3)
        bgVw.layer.shadowRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgVw.layer.shadowPath = UIBezierPath(roundedRect: bgVw.bounds, cornerRadius: 12).cgPath
    }
    
     @objc private func prevMonth() {
        moveCurrentPage(isNext: false)
    }
    
    @objc private func nextMonth() {
        moveCurrentPage(isNext: true)
    }
    
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
    
     func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int { 0 }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "attendanceCell", for: date, at: position) as! AttendanceCalendarCell
        
        let calendarSys = Calendar.current
        func isSameDay(_ d1: Date, _ d2: Date) -> Bool { calendarSys.isDate(d1, inSameDayAs: d2) }
        
        // Reset
        cell.setFullDayColor(.clear)
        cell.titleLabel.textColor = .label
        
        // Attendance
        if let status = attendanceDates.first(where: { isSameDay($0.date, date) })?.status {
            switch status {
            case .present:
                cell.setFullDayColor(.systemGreen)
            case .absent:
                cell.setFullDayColor(.systemRed)
            case .halfDay:
                cell.setHalfDayColors(topColor: .systemGreen, bottomColor: .systemRed)
            }
        } else if calendarSys.component(.weekday, from: date) == 1 {
            cell.setFullDayColor(.systemPurple) // Sunday
        }
        
        return cell
    }
}

