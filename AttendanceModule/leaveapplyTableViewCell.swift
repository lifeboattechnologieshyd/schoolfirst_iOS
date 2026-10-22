//
//  leaveapplyTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

class leaveapplyTableViewCell: UITableViewCell {

    @IBOutlet weak var Submitrequestbutton: UIButton!
    @IBOutlet weak var Uploadbutton: UIButton!
    @IBOutlet weak var Notetextfield: UITextField!
    @IBOutlet weak var Reasontextfield: UITextField!
    @IBOutlet weak var Durationtextfield: UITextField!
    @IBOutlet weak var Studentnametextfield: UITextField!
    @IBOutlet weak var Todatebutton: UIButton!
    @IBOutlet weak var Fromdatebutton: UIButton!
    @IBOutlet weak var LeavetypeLabel: UILabel!
    @IBOutlet weak var LeavetypedropdownButton: UIButton!
    @IBOutlet weak var Reasonscantainerview: UIView!

    // MARK: - Callbacks (handled by LeaveapplyVC)
    var onFromDateTap: (() -> Void)?
    var onToDateTap: (() -> Void)?
    var onLeaveTypeTap: (() -> Void)?
    var onSubmitTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        // Duration is calculated from dates — display only
        Durationtextfield.isUserInteractionEnabled = false

        Fromdatebutton.addTarget(
            self,
            action: #selector(fromDateButtonTapped),
            for: .touchUpInside
        )

        Todatebutton.addTarget(
            self,
            action: #selector(toDateButtonTapped),
            for: .touchUpInside
        )

        LeavetypedropdownButton.addTarget(
            self,
            action: #selector(leaveTypeButtonTapped),
            for: .touchUpInside
        )

        Submitrequestbutton.addTarget(
            self,
            action: #selector(submitButtonTapped),
            for: .touchUpInside
        )

        // Tapping the leave type label also opens the leave type card.
        LeavetypeLabel.isUserInteractionEnabled = true
        let labelTap = UITapGestureRecognizer(
            target: self,
            action: #selector(leaveTypeButtonTapped)
        )
        LeavetypeLabel.addGestureRecognizer(labelTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Actions

    @objc private func fromDateButtonTapped() {
        onFromDateTap?()
    }

    @objc private func toDateButtonTapped() {
        onToDateTap?()
    }

    @objc private func leaveTypeButtonTapped() {
        onLeaveTypeTap?()
    }

    @objc private func submitButtonTapped() {
        onSubmitTap?()
    }

    // MARK: - Public Updates (called by LeaveapplyVC)

    func setFromDateText(_ text: String?) {
        Fromdatebutton.setTitle(text ?? "Select date", for: .normal)
    }

    func setToDateText(_ text: String?) {
        Todatebutton.setTitle(text ?? "Select date", for: .normal)
    }

    func setLeaveTypeText(_ text: String?) {
        LeavetypeLabel.text = text ?? "Select leave type"
    }

    func setDurationText(_ text: String?) {
        Durationtextfield.text = text ?? ""
    }
}
