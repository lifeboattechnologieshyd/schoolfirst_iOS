//
//  AddleavenoteTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

protocol AddleavenoteTBLVCLLDelegate: AnyObject {
    func didTapSubmitLeaveNote(note: String)
    func didTapBackToAttendance()
}

class AddleavenoteTBLVCLL: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var SubmitnoteButton: UIButton!
    @IBOutlet weak var Documrntaploadbutton: UIButton!
    @IBOutlet weak var Addnotetextfield: UITextField!
    
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var Cantainerview: UIView!
    @IBOutlet weak var attendancetypeLabel: UILabel!
    @IBOutlet weak var RequestdateLabel: UILabel!
    @IBOutlet weak var Colorverticalview: UIView!
    
    weak var delegate: AddleavenoteTBLVCLLDelegate?
    
    /// Tracks whether this cell is in success mode
    private var isSubmittedMode = false
    
    /// Top-aligned note editor. A UITextField always centers its text
    /// vertically, so a transparent UITextView is laid exactly over the
    /// XIB text field. The XIB field keeps drawing its border/background —
    /// it just never shows text anymore.
    private var noteTextView: UITextView?
    private var notePlaceholderLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        SubmitnoteButton.addTarget(self, action: #selector(didTapSubmitNoteButton), for: .touchUpInside)
        
        setupTopAlignedNoteEditor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Top-Aligned Note Editor Setup
    private func setupTopAlignedNoteEditor() {
        guard noteTextView == nil,
              let tf = Addnotetextfield,
              let container = tf.superview else { return }
        
        // Mute the original field but keep its XIB styling (border, corners,
        // background) — it still draws the note box, just without text.
        tf.textColor = .clear
        tf.tintColor = .clear
        tf.isUserInteractionEnabled = false
        
        // Transparent text view pinned to the exact same frame —
        // UITextView is always top-aligned.
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = tf.font ?? .systemFont(ofSize: 15)
        tv.textColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
        tv.showsHorizontalScrollIndicator = false
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(tv) // added after the field → sits on top, receives touches
        
        NSLayoutConstraint.activate([
            tv.topAnchor.constraint(equalTo: tf.topAnchor),
            tv.bottomAnchor.constraint(equalTo: tf.bottomAnchor),
            tv.leadingAnchor.constraint(equalTo: tf.leadingAnchor),
            tv.trailingAnchor.constraint(equalTo: tf.trailingAnchor)
        ])
        noteTextView = tv
        
        // Placeholder label — top-aligned inside the text view
        let pl = UILabel()
        pl.text = "Enter your note here..."
        pl.font = tv.font
        pl.textColor = .placeholderText
        pl.numberOfLines = 0
        pl.translatesAutoresizingMaskIntoConstraints = false
        tv.addSubview(pl)
        
        NSLayoutConstraint.activate([
            pl.topAnchor.constraint(equalTo: tv.topAnchor, constant: 18),
            pl.leadingAnchor.constraint(equalTo: tv.leadingAnchor, constant: 22),
            pl.trailingAnchor.constraint(lessThanOrEqualTo: tv.trailingAnchor, constant: -18)
        ])
        notePlaceholderLabel = pl
        pl.isHidden = true
    }
    
    /// Current note text — from the top-aligned editor,
    /// falling back to the original outlet.
    private func currentNoteText() -> String {
        return noteTextView?.text ?? Addnotetextfield.text ?? ""
    }
    
    @objc private func didTapSubmitNoteButton() {
        if isSubmittedMode {
            delegate?.didTapBackToAttendance()
        } else {
            endEditing(true)
            delegate?.didTapSubmitLeaveNote(note: currentNoteText())
        }
    }
    
    // MARK: - Configure (Input Mode)
    func configure(attendanceStatus: String?, attendanceDate: String?) {
        isSubmittedMode = false
        
        // Attendance Type
        let status = nonEmptyText(attendanceStatus)
        attendancetypeLabel.text = status?
            .replacingOccurrences(of: "_", with: " ")
            .capitalized ?? "—"
        
        // Request Date
        RequestdateLabel.text = formattedDate(
            attendanceDate,
            format: "dd MMM yyyy"
        )
        
        // Original field stays muted (text handled by the top-aligned editor)
        Addnotetextfield.text = ""
        Addnotetextfield.isEnabled = true
        Addnotetextfield.placeholder = ""
        
        // Top-aligned editor — editable input mode
        noteTextView?.text = ""
        noteTextView?.isEditable = true
        noteTextView?.isUserInteractionEnabled = true
        noteTextView?.tintColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1)
        notePlaceholderLabel?.isHidden = false
        
        ReasonLabel.text = "Add note for the school"
        
        SubmitnoteButton.setTitle("Submit note", for: .normal)
        SubmitnoteButton.isEnabled = true
        
        Documrntaploadbutton.isHidden = false
    }
    
    // MARK: - Configure (Success Mode)
    func configureSuccess(data: AttendanceLateNoteData?) {
        isSubmittedMode = true
        
        // Attendance Type / Status
        let rawStatus = nonEmptyText(data?.status)
        attendancetypeLabel.text = rawStatus?
            .replacingOccurrences(of: "_", with: " ")
            .capitalized ?? "—"
        
        // Attendance Date
        RequestdateLabel.text = formattedDate(
            data?.attendanceDate,
            format: "dd MMM yyyy"
        )
        
        // Note Submitted — top-aligned, read-only
        let lateNote = nonEmptyText(data?.lateNote)
        let absentNote = nonEmptyText(data?.absentNote)
        let submittedNote = lateNote ?? absentNote ?? "—"
        
        Addnotetextfield.text = submittedNote
        Addnotetextfield.isEnabled = false
        Addnotetextfield.placeholder = ""
        
        // Top-aligned editor — read-only success mode
        noteTextView?.text = submittedNote
        noteTextView?.isEditable = false
        noteTextView?.tintColor = .clear // hides the cursor
        notePlaceholderLabel?.isHidden = true
        
        // Reason Label — show student and admission info
        let studentName = nonEmptyText(data?.student?.name) ?? UserManager.shared.resolvedStudentName
        let admissionNumber = nonEmptyText(data?.student?.admissionNumber) ?? "—"
        
        ReasonLabel.text = "\(studentName) · Admission no. \(admissionNumber)"
        
        // Change button to Back
        SubmitnoteButton.setTitle("← Back to Attendance", for: .normal)
        SubmitnoteButton.isEnabled = true
        
        Documrntaploadbutton.isHidden = true
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        notePlaceholderLabel?.isHidden = !textView.text.isEmpty
    }
    
    // MARK: - Handle Missing or Empty Values
    private func nonEmptyText(_ value: String?) -> String? {
        guard let text = value?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        return text
    }
    
    // MARK: - Date Formatting
    private func formattedDate(
        _ dateString: String?,
        format: String
    ) -> String {
        
        guard let dateString = nonEmptyText(dateString) else {
            return "—"
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
