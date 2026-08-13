//
//  ATDNCattendanceCollectionViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/08/26.
//

import UIKit

class ATDNCattendanceCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var NumberofdaysLbl: UILabel!
    @IBOutlet weak var Attendancetitle: UILabel!
    @IBOutlet weak var Backgroundview: UIView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        NumberofdaysLbl?.text  = nil
        Attendancetitle?.text  = nil
    }

    // MARK: - UI Setup
    private func setupUI() {
        Backgroundview.layer.cornerRadius  = 12
        Backgroundview.layer.borderWidth   = 1
        Backgroundview.layer.masksToBounds = true

        Attendancetitle.textAlignment  = .center
        NumberofdaysLbl.textAlignment  = .center

        Attendancetitle.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        NumberofdaysLbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }

    // MARK: - Configure
    /// - Parameters:
    ///   - title: "Present" / "Absent" / "Leave" / "Att. %"
    ///   - value: "18" / "5" / "2" / "72%"
    ///   - backgroundColor: light tint background
    ///   - borderColor: card border color
    ///   - textColor: title + value color
    func configure(title: String,
                   value: String,
                   backgroundColor: UIColor,
                   borderColor: UIColor,
                   textColor: UIColor) {

        Attendancetitle.text = title
        NumberofdaysLbl.text = value

        Backgroundview.backgroundColor  = backgroundColor
        Backgroundview.layer.borderColor = borderColor.cgColor

        Attendancetitle.textColor = textColor
        NumberofdaysLbl.textColor = textColor
    }
}
