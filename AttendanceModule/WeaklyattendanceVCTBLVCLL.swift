//
//  WeaklyattendanceVCTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

// MARK: - Delegate Protocol
protocol WeaklyattendanceVCTBLVCLLDelegate: AnyObject {
    func didChangeWeek(to newWeekStart: Date)
    func didSelectDay(date: Date)
}

class WeaklyattendanceVCTBLVCLL: UITableViewCell {

    @IBOutlet weak var TodaydayanddateLabel: UILabel!
    @IBOutlet weak var NuberofleavesandlateinweakLabel: UILabel!
    @IBOutlet weak var Todayattendancecellconatanerview: UIView!
    
    @IBOutlet weak var termanddatelabel: UILabel!
    @IBOutlet weak var Accademicyearlabel: UILabel!
    @IBOutlet weak var Datecardsviewcontroller: UIView!
    @IBOutlet weak var Datewithbuttonscantainerview: UIView!
    
    weak var delegate: WeaklyattendanceVCTBLVCLLDelegate?
    
    // MARK: - UI Elements
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let dateLabel = UILabel()
    private let termLabel = UILabel()
    
    // For Date Cards
    private let daysStackView = UIStackView()
    private var dayCards: [DayCardView] = []
    
    // State driven by configure()
    private var currentWeekStart: Date = Date()
    
    // Embedded Cell for "Today/Selected Day" view
    private var embeddedAttendanceCell: absentpresentlateTBLVCLL?
    
    // Styling
    private let primaryBlue = UIColor(red: 0.11, green: 0.31, blue: 0.61, alpha: 1.0)
    private let dateTextColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
    private let termTextColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDateContainer()
        setupDateCards()
        setupEmbeddedCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup Subviews
    private func setupEmbeddedCell() {
        let nib = UINib(nibName: "absentpresentlateTBLVCLL", bundle: nil)
        if let cell = nib.instantiate(withOwner: nil, options: nil).first as? absentpresentlateTBLVCLL {
            embeddedAttendanceCell = cell
            cell.translatesAutoresizingMaskIntoConstraints = false
            Todayattendancecellconatanerview.addSubview(cell)
            
            NSLayoutConstraint.activate([
                cell.topAnchor.constraint(equalTo: Todayattendancecellconatanerview.topAnchor),
                cell.bottomAnchor.constraint(equalTo: Todayattendancecellconatanerview.bottomAnchor),
                cell.leadingAnchor.constraint(equalTo: Todayattendancecellconatanerview.leadingAnchor),
                cell.trailingAnchor.constraint(equalTo: Todayattendancecellconatanerview.trailingAnchor)
            ])
        }
    }
    
    private func setupDateContainer() {
        Datewithbuttonscantainerview.subviews.forEach { $0.removeFromSuperview() }
        
        Datewithbuttonscantainerview.backgroundColor = .white
        Datewithbuttonscantainerview.layer.cornerRadius = 12
        Datewithbuttonscantainerview.layer.borderWidth = 1
        Datewithbuttonscantainerview.layer.borderColor = UIColor(red: 0.88, green: 0.91, blue: 0.94, alpha: 1.0).cgColor
        Datewithbuttonscantainerview.clipsToBounds = true
        
        let leftArrow = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        leftButton.setImage(leftArrow, for: .normal)
        leftButton.tintColor = primaryBlue
        leftButton.addTarget(self, action: #selector(didTapLeftArrow), for: .touchUpInside)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        
        let rightArrow = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        rightButton.setImage(rightArrow, for: .normal)
        rightButton.tintColor = primaryBlue
        rightButton.addTarget(self, action: #selector(didTapRightArrow), for: .touchUpInside)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        dateLabel.textColor = dateTextColor
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        termLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        termLabel.textColor = termTextColor
        termLabel.textAlignment = .center
        termLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textStackView = UIStackView(arrangedSubviews: [dateLabel, termLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .center
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        Datewithbuttonscantainerview.addSubview(leftButton)
        Datewithbuttonscantainerview.addSubview(textStackView)
        Datewithbuttonscantainerview.addSubview(rightButton)
        
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: Datewithbuttonscantainerview.leadingAnchor, constant: 16),
            leftButton.centerYAnchor.constraint(equalTo: Datewithbuttonscantainerview.centerYAnchor),
            leftButton.widthAnchor.constraint(equalToConstant: 40),
            leftButton.heightAnchor.constraint(equalToConstant: 40),
            
            rightButton.trailingAnchor.constraint(equalTo: Datewithbuttonscantainerview.trailingAnchor, constant: -16),
            rightButton.centerYAnchor.constraint(equalTo: Datewithbuttonscantainerview.centerYAnchor),
            rightButton.widthAnchor.constraint(equalToConstant: 40),
            rightButton.heightAnchor.constraint(equalToConstant: 40),
            
            textStackView.centerXAnchor.constraint(equalTo: Datewithbuttonscantainerview.centerXAnchor),
            textStackView.centerYAnchor.constraint(equalTo: Datewithbuttonscantainerview.centerYAnchor),
            textStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leftButton.trailingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: rightButton.leadingAnchor, constant: -10)
        ])
    }
    
    private func setupDateCards() {
        Datecardsviewcontroller.subviews.forEach { $0.removeFromSuperview() }
        
        daysStackView.axis = .horizontal
        daysStackView.spacing = 6
        daysStackView.distribution = .fillEqually
        daysStackView.translatesAutoresizingMaskIntoConstraints = false
        
        Datecardsviewcontroller.addSubview(daysStackView)
        
        NSLayoutConstraint.activate([
            daysStackView.topAnchor.constraint(equalTo: Datecardsviewcontroller.topAnchor),
            daysStackView.leadingAnchor.constraint(equalTo: Datecardsviewcontroller.leadingAnchor),
            daysStackView.trailingAnchor.constraint(equalTo: Datecardsviewcontroller.trailingAnchor),
            daysStackView.bottomAnchor.constraint(equalTo: Datecardsviewcontroller.bottomAnchor),
            daysStackView.heightAnchor.constraint(equalToConstant: 65)
        ])
        
        dayCards.removeAll()
        
        for i in 0..<5 {
            let card = DayCardView()
            card.tag = i
            let tap = UITapGestureRecognizer(target: self, action: #selector(dayCardTapped(_:)))
            card.addGestureRecognizer(tap)
            card.isUserInteractionEnabled = true
            
            dayCards.append(card)
            daysStackView.addArrangedSubview(card)
        }
    }
    
    // MARK: - Actions
    @objc private func didTapLeftArrow() {
        if let previousWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) {
            delegate?.didChangeWeek(to: previousWeek)
        }
    }
    
    @objc private func didTapRightArrow() {
        if let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) {
            delegate?.didChangeWeek(to: nextWeek)
        }
    }
    
    @objc private func dayCardTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        if let tappedDate = Calendar.current.date(byAdding: .day, value: index, to: currentWeekStart) {
            delegate?.didSelectDay(date: tappedDate)
        }
    }
    
    // MARK: - Configure Cell using State from VC
    func configure(
        weekStart: Date,
        selectedDate: Date,
        selectedRecord: FetchStudentAttendanceRecord,
        leaveCount: Int,
        lateCount: Int
    ) {
        self.currentWeekStart = weekStart
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        
        let endOfWeek = cal.date(byAdding: .day, value: 4, to: weekStart) ?? weekStart
        
        // 1. Update Top Date Range Label (e.g. 31 Aug - 4 Sep)
        let topDateFormatter = DateFormatter()
        topDateFormatter.dateFormat = "d MMM"
        let startStr = topDateFormatter.string(from: weekStart)
        let endStr = topDateFormatter.string(from: endOfWeek)
        dateLabel.text = "\(startStr) – \(endStr)"
        
        // Update Academic Year/Term (Static or dynamic if available)
        let termStartDate = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 1)) ?? Date()
        let weeksPassed = cal.dateComponents([.weekOfYear], from: termStartDate, to: weekStart).weekOfYear ?? 0
        termLabel.text = "Term 1 · Week \(max(1, weeksPassed + 1))"
        
        // 2. Update Mon-Fri Pills
        let pillDateFormatter = DateFormatter()
        pillDateFormatter.dateFormat = "dd MMM"
        let dayNameFormatter = DateFormatter()
        dayNameFormatter.dateFormat = "EEE"
        
        // Figure out which index matches selectedDate
        let selectedIndex = cal.dateComponents([.day], from: weekStart, to: selectedDate).day ?? 0
        
        for (i, card) in dayCards.enumerated() {
            if let date = cal.date(byAdding: .day, value: i, to: weekStart) {
                let dayStr = dayNameFormatter.string(from: date)
                let dateStr = pillDateFormatter.string(from: date)
                card.configure(day: dayStr, date: dateStr, selected: (i == selectedIndex))
            }
        }
        
        // 3. Update "Today / Selected Day" Date Label (e.g. Friday · 4 Sep)
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "EEEE · d MMM"
        TodaydayanddateLabel.text = fullDateFormatter.string(from: selectedDate)
        
        // 4. Update Summary Label (Leaves and Lates)
        let leaveText = leaveCount == 1 ? "1 leave" : "\(leaveCount) leaves"
        NuberofleavesandlateinweakLabel.text = "\(leaveText) · \(lateCount) late"
        
        // 5. Update Embedded Attendance Cell
        embeddedAttendanceCell?.configure(with: selectedRecord)
    }
}

// MARK: - Custom Date Card View (Unchanged logically, just cleaner)
class DayCardView: UIView {
    
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let selectedColor = UIColor(red: 0.11, green: 0.31, blue: 0.61, alpha: 1.0)
    private let unselectedDayColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
    private let unselectedDateColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)
    private let defaultBorderColor = UIColor(red: 0.88, green: 0.91, blue: 0.94, alpha: 1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = defaultBorderColor.cgColor
        clipsToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        dayLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        dayLabel.textColor = unselectedDayColor
        
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = unselectedDateColor
        
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(dateLabel)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(day: String, date: String, selected: Bool) {
        dayLabel.text = day
        dateLabel.text = date
        
        if selected {
            backgroundColor = selectedColor
            layer.borderWidth = 0
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            backgroundColor = .white
            layer.borderWidth = 1
            layer.borderColor = defaultBorderColor.cgColor
            dayLabel.textColor = unselectedDayColor
            dateLabel.textColor = unselectedDateColor
        }
    }
}
