//
//  HomeworkStudentTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkStudentTableViewCell1: UITableViewCell {

    @IBOutlet weak var Backgroungview: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Light Gray Shadow
        Backgroungview.layer.shadowColor = UIColor.lightGray.cgColor
        Backgroungview.layer.shadowOpacity = 0.4
        Backgroungview.layer.shadowOffset = CGSize(width: 0, height: 2)
        Backgroungview.layer.shadowRadius = 4
        Backgroungview.layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        Backgroungview.layer.shadowPath = UIBezierPath(rect: Backgroungview.bounds).cgPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
