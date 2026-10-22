//
//  WeaklyattendanceVCTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class WeaklyattendanceVCTBLVCLL: UITableViewCell {

    @IBOutlet weak var Datecardsviewcontroller: UIView!
    @IBOutlet weak var Datewithbuttonscantainerview: UIView!
    
    // MARK: - UI Elements
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let dateLabel = UILabel()
    private let termLabel = UILabel()
    
    // For Date Cards
    private let daysStackView = UIStackView()
    private var dayCards: [DayCardView] = []
    private var selectedDayIndex: Int = 4 // Defaulting to Friday to match Figma design
    
    // MARK: - Data Properties
    private var currentDate: Date = Date()
    
    // Match Figma styling
    private let primaryBlue = UIColor(red: 0.11, green: 0.31, blue: 0.61, alpha: 1.0) // Dark blue for arrows
    private let dateTextColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0) // Dark gray/black
    private let termTextColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0) // Light gray
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDateContainer()
        setupDateCards()
        updateDateDisplay()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup Top Date Container
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
    
    // MARK: - Setup Date Cards (Mon - Fri)
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
            daysStackView.heightAnchor.constraint(equalToConstant: 65) // Match Figma height
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
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
            currentDate = newDate
            updateDateDisplay()
        }
    }
    
    @objc private func didTapRightArrow() {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
            currentDate = newDate
            updateDateDisplay()
        }
    }
    
    @objc private func dayCardTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        selectedDayIndex = index
        updateDayCardsUI()
    }
    
    // MARK: - Update UI Logic
    private func updateDateDisplay() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2 // Force Monday
        
        let startOfWeek = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) ?? currentDate
        let endOfWeek = gregorian.date(byAdding: .day, value: 4, to: startOfWeek) ?? startOfWeek
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        let startDateString = dateFormatter.string(from: startOfWeek)
        let endDateString = dateFormatter.string(from: endOfWeek)
        
        dateLabel.text = "\(startDateString) – \(endDateString)"
        
        let termStartDate = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 1)) ?? Date()
        let weeksPassed = gregorian.dateComponents([.weekOfYear], from: termStartDate, to: startOfWeek).weekOfYear ?? 0
        let currentWeekNumber = max(1, weeksPassed + 1)
        termLabel.text = "Term 1 · Week \(currentWeekNumber)"
        
        // Populate the Day Cards
        for (index, card) in dayCards.enumerated() {
            if let date = gregorian.date(byAdding: .day, value: index, to: startOfWeek) {
                let dayStr = getDayString(for: date)
                let dateStr = dateFormatter.string(from: date)
                card.configure(day: dayStr, date: dateStr, selected: index == selectedDayIndex)
            }
        }
    }
    
    private func updateDayCardsUI() {
        for (index, card) in dayCards.enumerated() {
            card.setSelected(index == selectedDayIndex)
        }
    }
    
    private func getDayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue, Wed...
        return formatter.string(from: date)
    }
}

// MARK: - Custom Date Card View
class DayCardView: UIView {
    
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let selectedColor = UIColor(red: 0.11, green: 0.31, blue: 0.61, alpha: 1.0) // Dark blue
    private let unselectedDayColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
    private let unselectedDateColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)
    
    // ✅ FIXED: Renamed from 'borderColor' to avoid UIKit conflict
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
        stackView.isUserInteractionEnabled = false // Let the container view handle taps
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
        setSelected(selected)
    }
    
    func setSelected(_ selected: Bool) {
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
