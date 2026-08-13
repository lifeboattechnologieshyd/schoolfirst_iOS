//
//  PTMhomeTableViewCell1.swift
//  SchoolFirst
//

import UIKit

class PTMhomeTableViewCell1: UITableViewCell {

    @IBOutlet weak var Totalattendedview: UIView!
    @IBOutlet weak var UpcomingmeetingDateLbl: UILabel!
    // MARK: - Outlets
    @IBOutlet weak var TotalmeetingattendedcountLbl: UILabel!
    @IBOutlet weak var ViewcalendarButton: UIButton!
    @IBOutlet weak var StudentnameLBl: UILabel!
    @IBOutlet weak var CardsBackgroungView: UIView!
    @IBOutlet weak var upcomingCountLabel: UILabel!

    // MARK: - Callbacks
    var onDetailsTapped: (() -> Void)?
    var onCalendarTapped: (() -> Void)?
    var onAttendedHistoryTapped: (() -> Void)?   // ✅ NEW: Totalattendedview tap

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        ViewcalendarButton.addTarget(
            self,
            action: #selector(didTapCalendar),
            for: .touchUpInside
        )

        // ── ✅ NEW: Tap gesture on Totalattendedview ─────────────────────
        let attendedTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapAttendedView)
        )
        Totalattendedview.isUserInteractionEnabled = true
        Totalattendedview.addGestureRecognizer(attendedTap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StudentnameLBl.text                = nil
        upcomingCountLabel.text            = nil
        TotalmeetingattendedcountLbl.text  = nil
        UpcomingmeetingDateLbl.text        = nil // Added for cleanup
        onDetailsTapped                    = nil
        onCalendarTapped                   = nil
        onAttendedHistoryTapped            = nil // ✅ NEW: cleanup
    }

    // MARK: - Actions
    @objc func didTapDetails() {
        onDetailsTapped?()
    }

    @objc func didTapCalendar() {
        onCalendarTapped?()
    }

    // ✅ NEW: Totalattendedview tapped
    @objc func didTapAttendedView() {
        print("👆 Totalattendedview tapped")
        onAttendedHistoryTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
