//
//  HWSubjectWiseCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/11/25.
//

import UIKit

class HWSubjectWiseCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var doneBtn: UIButton!

    var trackerId: String?
    var subject: String?
    var onDoneTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.applyCardShadow()
        doneBtn.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trackerId = nil
        subject = nil
        onDoneTapped = nil
        doneBtn.isUserInteractionEnabled = true
    }

    @objc func doneBtnTapped() {
        onDoneTapped?()
    }

    func configure(detail: HomeworkDetail, trackerDetail: HomeworkTrackerDetail?) {
        lblSubject.text = detail.subject
        lblDescription.text = detail.description
        lblDescription.font = .lexend(.regular, size: 14)
        lblSubject.font = .lexend(.semiBold, size: 14)
        
        self.subject = detail.subject
        self.trackerId = trackerDetail?.id
        
        let status = trackerDetail?.status.lowercased() ?? ""
        let isDone = (status == "completed" || status == "done")
        
        updateDoneButtonUI(isDone: isDone)
    }

    func updateDoneButtonUI(isDone: Bool) {
        if isDone {
            doneBtn.setImage(UIImage(named: "done_check"), for: .normal)
            doneBtn.isUserInteractionEnabled = false
        } else {
            doneBtn.setImage(UIImage(named: "hw_check_mark"), for: .normal)
            doneBtn.isUserInteractionEnabled = true
        }
    }

    func markAsDone() {
        doneBtn.setImage(UIImage(named: "done_check"), for: .normal)
        doneBtn.isUserInteractionEnabled = false
    }
}
