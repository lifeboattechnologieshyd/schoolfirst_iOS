//
//  leaveapplyTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

class leaveapplyTableViewCell: UITableViewCell {

    @IBOutlet weak var Documentapploadbutton: UIButton!
    
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
    var onDocumentUploadTap: (() -> Void)?

    // Top-aligned note editor
    private var noteTextView: UITextView?
    private var notePlaceholderLabel: UILabel?

    /// Own label so "Upload" always renders (avoids XIB configuration issues)
    private var uploadTitleLabel: UILabel?

    private let uploadBlue = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1)
    private let uploadDark = UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

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

        LeavetypeLabel.isUserInteractionEnabled = true
        let labelTap = UITapGestureRecognizer(
            target: self,
            action: #selector(leaveTypeButtonTapped)
        )
        LeavetypeLabel.addGestureRecognizer(labelTap)

        setupDocumentButtons()
        setupTopAlignedNoteEditor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Document buttons
    private func setupDocumentButtons() {

        // Card button = full-row invisible hit target
        if let card = Documentapploadbutton {
            stripButtonTitle(card)
            card.backgroundColor = .clear
            card.addTarget(
                self,
                action: #selector(documentUploadButtonTapped),
                for: .touchUpInside
            )
        }

        // Upload button = tap target only; title drawn by uploadTitleLabel
        if let upload = Uploadbutton {
            stripButtonTitle(upload)
            upload.addTarget(
                self,
                action: #selector(documentUploadButtonTapped),
                for: .touchUpInside
            )
            upload.setContentCompressionResistancePriority(.required, for: .horizontal)
            upload.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }

        setupUploadTitleLabel()
    }

    /// Removes any visible title from a button (classic + iOS 15 configuration).
    private func stripButtonTitle(_ button: UIButton) {
        button.setTitle(nil, for: .normal)
        button.setTitle("", for: .normal)
        button.setAttributedTitle(nil, for: .normal)
        button.setTitleColor(.clear, for: .normal)
        button.tintColor = button === Uploadbutton ? uploadBlue : .clear
        button.titleLabel?.text = nil
        button.titleLabel?.isHidden = true

        if #available(iOS 15.0, *) {
            // Keep layout/insets from XIB, only clear text
            if var cfg = button.configuration {
                cfg.title = nil
                cfg.attributedTitle = nil
                button.configuration = cfg
            }
        }
    }

    /// Visible "Upload" / file-name label pinned to the trailing side of the attach row.
    private func setupUploadTitleLabel() {
        guard uploadTitleLabel == nil else { return }

        // Anchor parent: prefer Uploadbutton, else the card button's superview
        let anchorView: UIView? = Uploadbutton ?? Documentapploadbutton
        guard let anchor = anchorView,
              let container = anchor.superview else { return }

        let label = UILabel()
        label.text = "Upload"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = uploadBlue
        label.textAlignment = .right
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.isUserInteractionEnabled = false
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        // Pin to trailing area of the attach row (same place as design "Upload")
        var constraints: [NSLayoutConstraint] = [
            label.centerYAnchor.constraint(equalTo: anchor.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 130),
            label.heightAnchor.constraint(equalToConstant: 30)
        ]

        // If Uploadbutton exists and has real width, also align to it
        if let upload = Uploadbutton, upload !== Documentapploadbutton {
            constraints.append(
                label.leadingAnchor.constraint(greaterThanOrEqualTo: upload.leadingAnchor)
            )
        }

        NSLayoutConstraint.activate(constraints)

        // Above card button so it's always visible
        container.bringSubviewToFront(label)
        if let upload = Uploadbutton {
            container.bringSubviewToFront(upload)
            // label should stay visible — put it above upload's empty title
            container.bringSubviewToFront(label)
        }

        uploadTitleLabel = label
    }

    // MARK: - Top-Aligned Note Editor
    private func setupTopAlignedNoteEditor() {
        guard noteTextView == nil,
              let tf = Notetextfield,
              let container = tf.superview else { return }

        tf.textColor = .clear
        tf.tintColor = .clear
        tf.isUserInteractionEnabled = false
        tf.placeholder = nil

        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = tf.font ?? .systemFont(ofSize: 15)
        tv.textColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
        tv.tintColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1)
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = true
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        tv.textContainer.lineFragmentPadding = 0
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(tv)

        NSLayoutConstraint.activate([
            tv.topAnchor.constraint(equalTo: tf.topAnchor),
            tv.bottomAnchor.constraint(equalTo: tf.bottomAnchor),
            tv.leadingAnchor.constraint(equalTo: tf.leadingAnchor),
            tv.trailingAnchor.constraint(equalTo: tf.trailingAnchor)
        ])
        noteTextView = tv

        let pl = UILabel()
        pl.text = "Enter note (optional)"
        pl.font = tv.font
        pl.textColor = .placeholderText
        pl.numberOfLines = 0
        pl.translatesAutoresizingMaskIntoConstraints = false
        tv.addSubview(pl)

        NSLayoutConstraint.activate([
            pl.topAnchor.constraint(equalTo: tv.topAnchor, constant: 14),
            pl.leadingAnchor.constraint(equalTo: tv.leadingAnchor, constant: 14),
            pl.trailingAnchor.constraint(lessThanOrEqualTo: tv.trailingAnchor, constant: -14)
        ])
        notePlaceholderLabel = pl
        pl.isHidden = !(tv.text ?? "").isEmpty
    }

    func currentNoteText() -> String {
        return noteTextView?.text ?? Notetextfield.text ?? ""
    }

    func clearNoteText() {
        noteTextView?.text = ""
        Notetextfield.text = ""
        notePlaceholderLabel?.isHidden = false
    }

    /// Updates the visible Upload label (never touches broken button title).
    func setDocumentFileName(_ fileName: String?) {
        // Ensure label exists (cell reuse safety)
        if uploadTitleLabel == nil {
            setupUploadTitleLabel()
        }

        if let fileName = fileName, !fileName.isEmpty {
            let display: String
            if fileName.count > 16 {
                display = String(fileName.prefix(7)) + "…" + String(fileName.suffix(6))
            } else {
                display = fileName
            }
            uploadTitleLabel?.text = display
            uploadTitleLabel?.textColor = uploadDark
        } else {
            uploadTitleLabel?.text = "Upload"
            uploadTitleLabel?.textColor = uploadBlue
        }

        if let label = uploadTitleLabel {
            label.superview?.bringSubviewToFront(label)
        }
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

    @objc private func documentUploadButtonTapped() {
        onDocumentUploadTap?()
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

// MARK: - UITextViewDelegate
extension leaveapplyTableViewCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        notePlaceholderLabel?.isHidden = !textView.text.isEmpty
        Notetextfield.text = textView.text
    }
}
