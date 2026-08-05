//
//  TRSPRTpickupanddropUITableviewcell.swift
//  SchoolFirst
//

import UIKit

class TRSPRTpickupanddropUITableviewcell: UITableViewCell {

    @IBOutlet weak var segmentcontroller: UISegmentedControl!

    // Closure to notify the view controller when segment changes
    var onSegmentChange: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        segmentcontroller.addTarget(
            self,
            action: #selector(segmentValueChanged(_:)),
            for: .valueChanged
        )
    }

    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        onSegmentChange?(sender.selectedSegmentIndex)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
