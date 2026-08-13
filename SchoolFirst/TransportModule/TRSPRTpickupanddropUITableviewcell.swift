//
//  TRSPRTpickupanddropUITableviewcell.swift
//  SchoolFirst
//

import UIKit

class TRSPRTpickupanddropUITableviewcell: UITableViewCell {

    @IBOutlet weak var StudentNameLbl: UILabel!
    @IBOutlet weak var segmentcontroller: UISegmentedControl!

    // Closure to notify the view controller when segment changes
    var onSegmentChange: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        StudentNameLbl.text = UserManager.shared.resolvedStudentName
        setupSegmentAppearance()

        segmentcontroller.addTarget(
            self,
            action: #selector(segmentValueChanged(_:)),
            for: .valueChanged
        )
    }

    // MARK: - Segment Appearance
    // ✅ Selected segment title → WHITE
    // ✅ Unselected segment title → BLACK
    private func setupSegmentAppearance() {

        // Normal (unselected) state → Black text
        segmentcontroller.setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Selected state → White text
        segmentcontroller.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
    }

    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        onSegmentChange?(sender.selectedSegmentIndex)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
