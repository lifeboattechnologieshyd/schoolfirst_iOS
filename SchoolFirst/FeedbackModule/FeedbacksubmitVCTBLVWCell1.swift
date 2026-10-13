//
//  FeedbacksubmitVCTBLVWCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbacksubmitVCTBLVWCell1: UITableViewCell {

    @IBOutlet weak var feedbacksubjecttextfield: UITextField!
    @IBOutlet weak var catogerydropdownbutton: UIButton!
    @IBOutlet weak var submitbutton: UIButton!

    @IBOutlet weak var CatogeryLabel: UILabel!
    @IBOutlet weak var feedbackmessagetextview: UITextView!

    // MARK: - Callbacks
    var onCategoryDropdownTapped: (() -> Void)?
    var onSubmitTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        // Wire button targets in code (works regardless of Storyboard connections)
        catogerydropdownbutton.addTarget(self, action: #selector(categoryDropdownTapped), for: .touchUpInside)
        submitbutton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: - Button Actions
    @objc private func categoryDropdownTapped() {
        onCategoryDropdownTapped?()
    }

    @objc private func submitTapped() {
        onSubmitTapped?()
    }

    // MARK: - Public Accessors (used by VC when submitting)
    var subjectText: String {
        return feedbacksubjecttextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var messageText: String {
        return feedbackmessagetextview.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    // MARK: - Update Category Label (called after selecting from dropdown)
    func updateCategoryLabel(_ name: String) {
        CatogeryLabel.text = name
    }
}
