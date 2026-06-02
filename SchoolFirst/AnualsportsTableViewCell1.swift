//
//  AnualsportsTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 02/06/26.


import UIKit

class AnualsportsTableViewCell1: UITableViewCell {

    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var ReminderButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        DispatchQueue.main.async {
            self.ShareButton.layer.cornerRadius = 32
            self.ReminderButton.layer.cornerRadius = 32

            self.ShareButton.layer.masksToBounds = true
            self.ReminderButton.layer.masksToBounds = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        ShareButton.layer.cornerRadius = 25
        ReminderButton.layer.cornerRadius = 25
    }
}
