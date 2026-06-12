//
//  HomeworkDetailsTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var Containerview2: UIView!
    @IBOutlet weak var Cantainerview1: UIView!

    @IBOutlet weak var Containerview4: UIView!
    @IBOutlet weak var Containerview3: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        setupShadow(for: Cantainerview1)
        setupShadow(for: Containerview2)
        setupShadow(for: Containerview3)
        setupShadow(for: Containerview4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        Cantainerview1.layer.shadowPath = UIBezierPath(
            rect: Cantainerview1.bounds
        ).cgPath

        Containerview2.layer.shadowPath = UIBezierPath(
            rect: Containerview2.bounds
        ).cgPath
        
        Containerview3.layer.shadowPath = UIBezierPath(
            rect: Containerview3.bounds
        ).cgPath
        
        Containerview4.layer.shadowPath = UIBezierPath(
            rect: Containerview4.bounds
        ).cgPath
    }

    private func setupShadow(for view: UIView) {
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 2
        view.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
