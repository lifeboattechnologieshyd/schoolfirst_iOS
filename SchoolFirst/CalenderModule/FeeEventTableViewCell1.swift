//
//  FeeEventTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 01/06/26.
//



import UIKit

class FeeEventTableViewCell1: UITableViewCell {

    @IBOutlet weak var ReminderButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        ReminderButton.clipsToBounds = true

        // Optional shadow like Figma
        ReminderButton.layer.shadowColor = UIColor.black.cgColor
        ReminderButton.layer.shadowOpacity = 0.15
        ReminderButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        ReminderButton.layer.shadowRadius = 8
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Pill Shape
        ReminderButton.layer.cornerRadius = ReminderButton.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
