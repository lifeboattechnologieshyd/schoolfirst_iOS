//
//  FeedbacksubmitVCTBLVWCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbacksubmitVCTBLVWCell1: UITableViewCell {

    @IBOutlet weak var NumberofcharectersLabel: UILabel!
    @IBOutlet weak var feedbacksubjecttextfield: UITextField!
    @IBOutlet weak var catogerydropdownbutton: UIButton!
    @IBOutlet weak var submitbutton: UIButton!

    @IBOutlet weak var CatogeryLabel: UILabel!
    @IBOutlet weak var feedbackmessagetextview: UITextView!

    // MARK: - Character Limit
    private let maxMessageCharacters: Int = 1000

    // MARK: - Callbacks
    var onCategoryDropdownTapped: (() -> Void)?
    var onSubmitTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        // Wire button targets in code (works regardless of Storyboard connections)
        catogerydropdownbutton.addTarget(self, action: #selector(categoryDropdownTapped), for: .touchUpInside)
        submitbutton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        // ✅ Character count setup
        setupMessageTextView()
        updateCharacterCountLabel()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Keep label in sync if cell is reused
        updateCharacterCountLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - ✅ Message TextView Setup (delegate + initial count)
    private func setupMessageTextView() {
        feedbackmessagetextview.delegate = self
        // Optional: avoid unlimited scrolling height issues while typing
        feedbackmessagetextview.isScrollEnabled = true
    }

    // MARK: - ✅ Update "15/1000 characters" label
    private func updateCharacterCountLabel() {
        let count = feedbackmessagetextview.text?.count ?? 0
        NumberofcharectersLabel.text = "\(count)/\(maxMessageCharacters) characters"
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

    // MARK: - Update Category Label
    func updateCategoryLabel(_ name: String) {
        CatogeryLabel.text = name
    }
    
    // MARK: - ✅ Setup Native Dropdown Menu (iOS 14+)
    func setupMenu(options: [(id: String, name: String)], selectedId: String?, selectionHandler: @escaping (String, String) -> Void) {
        if #available(iOS 14.0, *) {
            if options.isEmpty {
                // If no categories yet, disable menu so the normal button tap works (shows loading/error alert)
                catogerydropdownbutton.menu = nil
                catogerydropdownbutton.showsMenuAsPrimaryAction = false
            } else {
                // Create native dropdown attached directly to the button
                let actions = options.map { option in
                    UIAction(title: option.name, state: option.id == selectedId ? .on : .off) { _ in
                        selectionHandler(option.id, option.name)
                    }
                }
                let menu = UIMenu(title: "", children: actions)
                catogerydropdownbutton.menu = menu
                catogerydropdownbutton.showsMenuAsPrimaryAction = true
            }
        }
    }
}

// MARK: - ✅ UITextViewDelegate (character limit + live count)
extension FeedbacksubmitVCTBLVWCell1: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        // Live update label while typing / deleting / pasting
        updateCharacterCountLabel()
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {

        // Current text
        let currentText = textView.text ?? ""

        // Prevent crash on invalid range
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }

        // Text after this change
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // Allow only up to 1000 characters
        if updatedText.count <= maxMessageCharacters {
            return true
        }

        // If paste would exceed limit, trim to remaining allowed chars
        let remaining = maxMessageCharacters - currentText.count + range.length
        if remaining > 0, text.count > remaining {
            let allowed = String(text.prefix(remaining))
            textView.text = currentText.replacingCharacters(in: stringRange, with: allowed)
            updateCharacterCountLabel()
            // Move cursor to end of inserted text
            let cursorOffset = range.location + allowed.count
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: cursorOffset) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }

        return false
    }
}
