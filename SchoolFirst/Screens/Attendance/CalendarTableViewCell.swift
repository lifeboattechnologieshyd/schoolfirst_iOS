//
//  CalendarTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 29/10/25.
//

import UIKit
import FSCalendar

class CalendarTableViewCell: UITableViewCell, FSCalendarDelegate, FSCalendarDataSource {

    let calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.scope = .month
        cal.firstWeekday = 1
        return cal
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCalendar()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCalendar()
    }

    private func setupCalendar() {
        contentView.addSubview(calendar)
        calendar.delegate = self
        calendar.dataSource = self

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: contentView.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            calendar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

     func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Selected date: \(date)")
    }
}

