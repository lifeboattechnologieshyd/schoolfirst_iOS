//
//  CalenderVCTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 03/06/26.
//

import UIKit
import FSCalendar

class CalenderVCTableViewCell1: UITableViewCell {

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

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Event Date Mapping (Day -> Color)
    
    private let eventDates: [Int: UIColor] = [
        1  : .systemOrange,   // Orange → Fee Event
        2  : .systemGreen,    // Green  → Annual Sports
        7  : .systemRed,      // Red    → Exam Event
        10 : .systemPurple,   // Purple → P-T Meeting (was Blue, now purple as per Figma)
        16 : .systemBlue      // Blue   → P-T Meeting
    ]
    
    private let multiColorDay: Int = 15  // Day 15 has multiple events

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCalendar()
        setupCustomHeader()
        updateMonthLabel()
        setupTodayFocusCards()
    }

    // MARK: - Calendar Setup

    private func setupCalendar() {

        calendarView.delegate = self
        calendarView.dataSource = self

        calendarView.scope = .month
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal

        // Hide Default Header
        calendarView.headerHeight = 0
        calendarView.appearance.headerMinimumDissolvedAlpha = 0

        // Background
        calendarView.layer.cornerRadius = 16
        calendarView.clipsToBounds = true

        // Weekdays
        calendarView.appearance.weekdayTextColor = .darkGray
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 13, weight: .medium)

        // Dates
        calendarView.appearance.titleDefaultColor = .black
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.titlePlaceholderColor = .lightGray
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

        // Today Date - Disable default styling
        calendarView.appearance.todayColor = .clear
        calendarView.appearance.titleTodayColor = .black

        // Selected Date - Disable default blue circle
        calendarView.appearance.selectionColor = .clear
        calendarView.appearance.titleSelectionColor = .black

        // Make event dates rounded rectangle (filled)
        calendarView.appearance.borderRadius = 0.4
        
        // Register the multi-color cell
        calendarView.register(
            MultiColorCalendarCell.self,
            forCellReuseIdentifier: "MultiColorCalendarCell"
        )
        
        // Adjust row height for better filled look
        calendarView.rowHeight = 48
    }

    // MARK: - Custom Header

    private func setupCustomHeader() {

        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerContainerView)

        // Month Label
        monthYearLabel.translatesAutoresizingMaskIntoConstraints = false
        monthYearLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        monthYearLabel.textColor = .black
        monthYearLabel.textAlignment = .left
        headerContainerView.addSubview(monthYearLabel)

        // Previous Button
        previousButton.translatesAutoresizingMaskIntoConstraints = false

        let previousImage = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .bold
            )
        )

        previousButton.setImage(previousImage, for: .normal)
        previousButton.tintColor = .darkGray

        previousButton.backgroundColor = UIColor(
            red: 245/255,
            green: 236/255,
            blue: 153/255,
            alpha: 1.0
        )

        previousButton.layer.cornerRadius = 16
        previousButton.clipsToBounds = true

        previousButton.addTarget(
            self,
            action: #selector(previousMonthTapped),
            for: .touchUpInside
        )

        headerContainerView.addSubview(previousButton)

        // Next Button
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        let nextImage = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .bold
            )
        )

        nextButton.setImage(nextImage, for: .normal)
        nextButton.tintColor = .darkGray

        nextButton.backgroundColor = UIColor(
            red: 245/255,
            green: 236/255,
            blue: 153/255,
            alpha: 1.0
        )

        nextButton.layer.cornerRadius = 16
        nextButton.clipsToBounds = true

        nextButton.addTarget(
            self,
            action: #selector(nextMonthTapped),
            for: .touchUpInside
        )

        headerContainerView.addSubview(nextButton)

        NSLayoutConstraint.activate([

            headerContainerView.leadingAnchor.constraint(
                equalTo: calendarView.leadingAnchor,
                constant: 12
            ),
            headerContainerView.trailingAnchor.constraint(
                equalTo: calendarView.trailingAnchor,
                constant: -12
            ),
            headerContainerView.bottomAnchor.constraint(
                equalTo: calendarView.topAnchor
            ),
            headerContainerView.heightAnchor.constraint(
                equalToConstant: 40
            ),

            monthYearLabel.leadingAnchor.constraint(
                equalTo: headerContainerView.leadingAnchor
            ),
            monthYearLabel.centerYAnchor.constraint(
                equalTo: headerContainerView.centerYAnchor
            ),

            nextButton.trailingAnchor.constraint(
                equalTo: headerContainerView.trailingAnchor
            ),
            nextButton.centerYAnchor.constraint(
                equalTo: headerContainerView.centerYAnchor
            ),
            nextButton.widthAnchor.constraint(equalToConstant: 32),
            nextButton.heightAnchor.constraint(equalToConstant: 32),

            previousButton.trailingAnchor.constraint(
                equalTo: nextButton.leadingAnchor,
                constant: -8
            ),
            previousButton.centerYAnchor.constraint(
                equalTo: headerContainerView.centerYAnchor
            ),
            previousButton.widthAnchor.constraint(equalToConstant: 32),
            previousButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // MARK: - Button Actions

    @objc private func previousMonthTapped() {
        moveMonth(by: -1)
    }

    @objc private func nextMonthTapped() {
        moveMonth(by: 1)
    }

    private func moveMonth(by value: Int) {

        let currentPage = calendarView.currentPage

        if let newDate = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: currentPage
        ) {
            calendarView.setCurrentPage(newDate, animated: true)
        }
    }

    private func updateMonthLabel() {
        monthYearLabel.text = dateFormatter.string(from: calendarView.currentPage)
    }
}

// MARK: - FSCalendar Delegate

extension CalenderVCTableViewCell1: FSCalendarDelegate,
                                    FSCalendarDataSource,
                                    FSCalendarDelegateAppearance {

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
    }

    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {

        let day = Calendar.current.component(.day, from: date)
        let isCurrentMonth = Calendar.current.isDate(
            date,
            equalTo: calendar.currentPage,
            toGranularity: .month
        )
        
        if !isCurrentMonth {
            return .lightGray
        }
        
        // White text for filled dates
        if eventDates[day] != nil || day == multiColorDay {
            return .white
        }
        
        return .black
    }
    
    // MARK: - Fill Color for Event Dates
    
    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        fillDefaultColorFor date: Date
    ) -> UIColor? {
        
        let day = Calendar.current.component(.day, from: date)
        let isCurrentMonth = Calendar.current.isDate(
            date,
            equalTo: calendar.currentPage,
            toGranularity: .month
        )
        
        guard isCurrentMonth else { return nil }
        
        // Multi-color day → handled by custom cell, return clear here
        if day == multiColorDay {
            return .clear
        }
        
        // Return mapped event color
        return eventDates[day]
    }
    
    // MARK: - Custom Cell for Multi-Color Date
    
    func calendar(
        _ calendar: FSCalendar,
        cellFor date: Date,
        at position: FSCalendarMonthPosition
    ) -> FSCalendarCell {
        
        let day = Calendar.current.component(.day, from: date)
        let isCurrentMonth = Calendar.current.isDate(
            date,
            equalTo: calendar.currentPage,
            toGranularity: .month
        )
        
        let cell = calendar.dequeueReusableCell(
            withIdentifier: "MultiColorCalendarCell",
            for: date,
            at: position
        ) as! MultiColorCalendarCell
        
        // Show multi-color only for day 15 in current month
        cell.showMultiColor(day == multiColorDay && isCurrentMonth)
        
        return cell
    }
    
    // MARK: - Date Selection
    
    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        let day = Calendar.current.component(.day, from: date)
        
        // Multi-color date (day 15)
        if day == multiColorDay {
            onMultipleEventsTapped?()
        } else {
            switch eventDates[day] {
                
            case .some(let color) where color == .systemOrange:
                onFeeEventDateTapped?()
                
            case .some(let color) where color == .systemGreen:
                onAnnualSportsDayTapped?()
                
            case .some(let color) where color == .systemRed:
                onExamEventTapped?()
                
            case .some(let color) where color == .systemBlue, .some(let color) where color == .systemPurple:
                onPTMeetingTapped?()
                
            default:
                break
            }
        }
        
        // Deselect after small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            calendar.deselect(date)
        }
    }
    
    // MARK: - Today Focus Cards
    
    private func setupTodayFocusCards() {

        let cardBackgroundColor = UIColor(
            red: 241/255,
            green: 236/255,
            blue: 204/255,
            alpha: 1.0
        )

        let card1 = UIView()
        card1.translatesAutoresizingMaskIntoConstraints = false
        card1.backgroundColor = cardBackgroundColor
        card1.layer.cornerRadius = 18

        let iconCircle1 = UIView()
        iconCircle1.translatesAutoresizingMaskIntoConstraints = false
        iconCircle1.backgroundColor = UIColor(
            red: 244/255,
            green: 213/255,
            blue: 213/255,
            alpha: 1.0
        )
        iconCircle1.layer.cornerRadius = 22

        let icon1 = UIImageView()
        icon1.translatesAutoresizingMaskIntoConstraints = false
        icon1.image = UIImage(systemName: "doc.text")
        icon1.tintColor = UIColor.brown

        let title1 = UILabel()
        title1.translatesAutoresizingMaskIntoConstraints = false
        title1.text = "Math Quiz: Leo"
        title1.font = .systemFont(ofSize: 18, weight: .medium)

        let subtitle1 = UILabel()
        subtitle1.translatesAutoresizingMaskIntoConstraints = false
        subtitle1.text = "09:00 AM • Room 302"
        subtitle1.textColor = .darkGray
        subtitle1.font = .systemFont(ofSize: 14)

        let card2 = UIView()
        card2.translatesAutoresizingMaskIntoConstraints = false
        card2.backgroundColor = cardBackgroundColor
        card2.layer.cornerRadius = 18

        let iconCircle2 = UIView()
        iconCircle2.translatesAutoresizingMaskIntoConstraints = false
        iconCircle2.backgroundColor = UIColor(
            red: 203/255,
            green: 231/255,
            blue: 255/255,
            alpha: 1.0
        )
        iconCircle2.layer.cornerRadius = 22

        let icon2 = UIImageView()
        icon2.translatesAutoresizingMaskIntoConstraints = false
        icon2.image = UIImage(systemName: "person.3.fill")
        icon2.tintColor = .systemTeal

        let title2 = UILabel()
        title2.translatesAutoresizingMaskIntoConstraints = false
        title2.text = "PTA Meeting"
        title2.font = .systemFont(ofSize: 18, weight: .medium)

        let subtitle2 = UILabel()
        subtitle2.translatesAutoresizingMaskIntoConstraints = false
        subtitle2.text = "03:30 PM • Main Hall"
        subtitle2.textColor = .darkGray
        subtitle2.font = .systemFont(ofSize: 14)

        TodayeventsContainerview.addSubview(card1)
        TodayeventsContainerview.addSubview(card2)

        card1.addSubview(iconCircle1)
        iconCircle1.addSubview(icon1)
        card1.addSubview(title1)
        card1.addSubview(subtitle1)

        card2.addSubview(iconCircle2)
        iconCircle2.addSubview(icon2)
        card2.addSubview(title2)
        card2.addSubview(subtitle2)

        NSLayoutConstraint.activate([

            card1.leadingAnchor.constraint(equalTo: TodayeventsContainerview.leadingAnchor, constant: 18),
            card1.trailingAnchor.constraint(equalTo: TodayeventsContainerview.trailingAnchor, constant: -18),
            card1.topAnchor.constraint(equalTo: TodayeventsContainerview.topAnchor, constant: 80),
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

            title1.leadingAnchor.constraint(equalTo: iconCircle1.trailingAnchor, constant: 16),
            title1.topAnchor.constraint(equalTo: card1.topAnchor, constant: 20),

            subtitle1.leadingAnchor.constraint(equalTo: title1.leadingAnchor),
            subtitle1.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 4),

            iconCircle2.leadingAnchor.constraint(equalTo: card2.leadingAnchor, constant: 16),
            iconCircle2.centerYAnchor.constraint(equalTo: card2.centerYAnchor),
            iconCircle2.widthAnchor.constraint(equalToConstant: 44),
            iconCircle2.heightAnchor.constraint(equalToConstant: 44),

            icon2.centerXAnchor.constraint(equalTo: iconCircle2.centerXAnchor),
            icon2.centerYAnchor.constraint(equalTo: iconCircle2.centerYAnchor),

            title2.leadingAnchor.constraint(equalTo: iconCircle2.trailingAnchor, constant: 16),
            title2.topAnchor.constraint(equalTo: card2.topAnchor, constant: 20),

            subtitle2.leadingAnchor.constraint(equalTo: title2.leadingAnchor),
            subtitle2.topAnchor.constraint(equalTo: title2.bottomAnchor, constant: 4)
        ])
    }
}
