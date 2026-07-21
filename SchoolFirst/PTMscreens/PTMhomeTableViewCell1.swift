//
//  PTMhomeTableViewCell1.swift
//  SchoolFirst
//

import UIKit

class PTMhomeTableViewCell1: UITableViewCell {

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

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        ViewcalendarButton.addTarget(
            self,
            action: #selector(didTapCalendar),
            for: .touchUpInside
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StudentnameLBl.text                = nil
        upcomingCountLabel.text            = nil
        TotalmeetingattendedcountLbl.text  = nil
        UpcomingmeetingDateLbl.text        = nil // Added for cleanup
        onDetailsTapped                    = nil
        onCalendarTapped                   = nil
    }

    // MARK: - Actions
    @objc func didTapDetails() {
        onDetailsTapped?()
    }

    @objc func didTapCalendar() {
        onCalendarTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
