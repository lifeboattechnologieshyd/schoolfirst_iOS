//
//  MeetingdeclinepopupVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 27/07/26.
//

import UIKit

class MeetingdeclinepopupVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var otherLbl: UILabel!
    @IBOutlet weak var outoftownLbl: UILabel!
    @IBOutlet weak var personalemergencyLbl: UILabel!
    @IBOutlet weak var GobackButton: UIButton!
    @IBOutlet weak var ConfirmdeclineButton: UIButton!

    // MARK: - Public Properties (set from PTMmeetingdetailsVC)
    var meeting   : PTMMeeting?
    var meetingID : String = ""
    var studentID : String = ""
    var schoolID  : String = ""

    // MARK: - Private State
    private var selectedRemark: String = ""

    // Predefined remark options
    private let remarkOptions: [String] = [
        "Personal Emergency",
        "Out of Town",
        "Other"
    ]

    // Track which option label is currently selected
    private var selectedLabel: UILabel?

    // ✅ NEW: Checkmark image views for each label (added programmatically)
    private var personalCheckmark : UIImageView?
    private var outOfTownCheckmark: UIImageView?
    private var otherCheckmark    : UIImageView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCheckmarks()   // ← NEW
        setupGestures()
        setupTextField()

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📌 MeetingdeclinepopupVC — viewDidLoad")
        print("   meetingID : \(meetingID.isEmpty ? "⚠️ EMPTY" : meetingID)")
        print("   studentID : \(studentID.isEmpty ? "⚠️ EMPTY" : studentID)")
        print("   schoolID  : \(schoolID.isEmpty  ? "⚠️ EMPTY" : schoolID)")
        print("   meeting   : \(meeting?.title ?? "nil")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Setup UI
    private func setupUI() {
        ConfirmdeclineButton.layer.cornerRadius = 8
        ConfirmdeclineButton.clipsToBounds      = true

        GobackButton.layer.cornerRadius = 8
        GobackButton.clipsToBounds      = true

        // Initially hide textfield (shown only when "Other" is selected)
        textfield.isHidden = true
    }

    // MARK: - ✅ NEW: Setup Checkmark Icons on Right Side of Each Label
    private func setupCheckmarks() {
        personalCheckmark  = addCheckmark(to: personalemergencyLbl)
        outOfTownCheckmark = addCheckmark(to: outoftownLbl)
        otherCheckmark     = addCheckmark(to: otherLbl)

        // Initially all hidden
        personalCheckmark?.isHidden  = true
        outOfTownCheckmark?.isHidden = true
        otherCheckmark?.isHidden     = true
    }

    // MARK: - ✅ NEW: Add Checkmark Image to a Label
    private func addCheckmark(to label: UILabel) -> UIImageView {

        // ── Create checkmark image view ──────────────────────────────
        let checkmark = UIImageView()
        checkmark.translatesAutoresizingMaskIntoConstraints = false

        // SF Symbol → blue filled checkmark circle
        let config = UIImage.SymbolConfiguration(
            pointSize: 20,
            weight   : .medium
        )
        checkmark.image = UIImage(
            systemName: "checkmark.circle.fill",
            withConfiguration: config
        )?.withTintColor(
            UIColor(
                red: 0/255,
                green: 51/255,
                blue: 191/255,
                alpha: 1
            ),
            renderingMode: .alwaysOriginal
        )
        checkmark.contentMode = .scaleAspectFit

        // ── Add checkmark to label's superview (parent container) ───
        guard let parent = label.superview else {
            print("⚠️ addCheckmark: label has no superview")
            return checkmark
        }

        parent.addSubview(checkmark)

        // ── Constraints — pin to right side of label ─────────────────
        NSLayoutConstraint.activate([
            checkmark.centerYAnchor.constraint(
                equalTo: label.centerYAnchor
            ),
            checkmark.trailingAnchor.constraint(
                equalTo: label.trailingAnchor,
                constant: 134   // ← 12pt padding from right edge
            ),
            checkmark.widthAnchor.constraint(equalToConstant: 22),
            checkmark.heightAnchor.constraint(equalToConstant: 22)
        ])

        return checkmark
    }

    private func setupTextField() {
        textfield.placeholder   = "Enter your reason..."
        textfield.borderStyle   = .roundedRect
        textfield.returnKeyType = .done
        textfield.delegate      = self
    }

    // MARK: - Setup Tap Gestures on Remark Labels
    private func setupGestures() {
        let personalTap = UITapGestureRecognizer(
            target: self,
            action: #selector(personalEmergencyTapped)
        )
        personalemergencyLbl.isUserInteractionEnabled = true
        personalemergencyLbl.addGestureRecognizer(personalTap)

        let outOfTownTap = UITapGestureRecognizer(
            target: self,
            action: #selector(outOfTownTapped)
        )
        outoftownLbl.isUserInteractionEnabled = true
        outoftownLbl.addGestureRecognizer(outOfTownTap)

        let otherTap = UITapGestureRecognizer(
            target: self,
            action: #selector(otherTapped)
        )
        otherLbl.isUserInteractionEnabled = true
        otherLbl.addGestureRecognizer(otherTap)

        // Dismiss keyboard on tap outside
        let dismissTap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    // MARK: - Label Style Helper (kept commented as you had)
    private func styleLabel(_ label: UILabel, selected: Bool) {
        label.layer.cornerRadius  = 8
        label.layer.masksToBounds = true
        label.layer.borderWidth   = 1.5

        if selected {
            label.layer.borderColor = UIColor.systemBlue.cgColor
            label.backgroundColor   = UIColor.systemBlue.withAlphaComponent(0.1)
            label.textColor         = UIColor.systemBlue
        } else {
            label.layer.borderColor = UIColor.lightGray.cgColor
            label.backgroundColor   = UIColor.white
            label.textColor         = UIColor.darkGray
        }
    }

    // MARK: - Remark Selection Actions
    @objc private func personalEmergencyTapped() {
        selectRemark("Personal Emergency", label: personalemergencyLbl)
    }

    @objc private func outOfTownTapped() {
        selectRemark("Out of Town", label: outoftownLbl)
    }

    @objc private func otherTapped() {
        selectRemark("Other", label: otherLbl)
    }

    private func selectRemark(_ remark: String, label: UILabel) {

        // Select new
        selectedRemark = remark
        selectedLabel  = label

        // ✅ Update checkmark visibility
        updateCheckmarks(for: remark)

        print("✅ Remark selected: \(remark)")

        // Show textfield only for "Other"
        if remark == "Other" {
            textfield.isHidden = false
            textfield.becomeFirstResponder()
        } else {
            textfield.isHidden = true
            textfield.text     = ""
            dismissKeyboard()
        }
    }

    // MARK: - ✅ NEW: Update Checkmark Visibility Based on Selection
    private func updateCheckmarks(for remark: String) {

        // Hide all first
        personalCheckmark?.isHidden  = true
        outOfTownCheckmark?.isHidden = true
        otherCheckmark?.isHidden     = true

        // Show only selected one
        switch remark {
        case "Personal Emergency":
            personalCheckmark?.isHidden  = false
        case "Out of Town":
            outOfTownCheckmark?.isHidden = false
        case "Other":
            otherCheckmark?.isHidden     = false
        default:
            break
        }

        print("🔵 Checkmark shown for: \(remark)")
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Button Actions
    @IBAction func GobackButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @IBAction func ConfirmdeclineButtonTapped(_ sender: UIButton) {
        // Determine final remarks
        var finalRemarks = selectedRemark

        // If "Other" selected, use text from textfield
        if selectedRemark == "Other" {
            let typedText = textfield.text?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""
            if typedText.isEmpty {
                showAlert(
                    title: "Remarks Required",
                    message: "Please enter your reason."
                )
                return
            }
            finalRemarks = typedText
        } else if selectedRemark.isEmpty {
            showAlert(
                title: "Select Reason",
                message: "Please select a reason for declining."
            )
            return
        }

        print("✅ Confirm Decline tapped")
        print("   Remarks   : \(finalRemarks)")
        print("   meetingID : \(meetingID)")
        print("   studentID : \(studentID)")

        postDeclineResponse(remarks: finalRemarks)
    }

    // MARK: - POST Parent Response (NOT_ATTENDING)
    private func postDeclineResponse(remarks: String) {
        let schoolId  = schoolID.isEmpty  ? UserManager.shared.resolvedSchoolID  : schoolID
        let studentId = studentID.isEmpty ? UserManager.shared.resolvedStudentID : studentID

        guard !meetingID.isEmpty, !studentId.isEmpty else {
            print("❌ postDeclineResponse: Missing meetingID or studentID")
            showAlert(title: "Error", message: "Missing meeting information.")
            return
        }

        // student_id goes in JSON body
        let baseURL   = API.BASE_URL.hasSuffix("/")
                        ? String(API.BASE_URL.dropLast())
                        : API.BASE_URL
        let urlString = "\(baseURL)/ptm/parent-response/\(meetingID)"

        print("📡 POST Decline Response")
        print("   URL       : \(urlString)")
        print("   studentId : \(studentId)")
        print("   schoolId  : \(schoolId)")
        print("   status    : NOT_ATTENDING")
        print("   remarks   : \(remarks)")

        // Show loading
        let loadingAlert = UIAlertController(
            title: nil,
            message: "Submitting...",
            preferredStyle: .alert
        )
        let spinner = UIActivityIndicatorView(
            frame: CGRect(x: 10, y: 5, width: 50, height: 50)
        )
        spinner.hidesWhenStopped = true
        spinner.style            = .medium
        spinner.startAnimating()
        loadingAlert.view.addSubview(spinner)
        present(loadingAlert, animated: true)

        let bodyParams: [String: Any] = [
            "student_id":      studentId,
            "response_status": PTMResponseStatus.notAttending.rawValue,
            "remarks":         remarks
        ]

        print("   bodyParams: \(bodyParams)")

        NetworkManager.shared.request(
            urlString: urlString,
            method: .POST,
            requiresAuth: true,
            parameters: bodyParams,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<PTMParentResponseData>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let response):
                        print("✅ Decline Response API success")
                        print("   responseStatus : \(response.data?.responseStatus      ?? "nil")")
                        print("   respondedAt    : \(response.data?.formattedRespondedAt ?? "nil")")
                        if response.success {
                            self.navigateToDeclinedSuccess(
                                responseData: response.data,
                                remarks: remarks
                            )
                        } else {
                            self.showAlert(
                                title: "Error",
                                message: response.description.isEmpty
                                    ? "Failed to decline. Please try again."
                                    : response.description
                            )
                        }
                    case .failure(let error):
                        print("❌ Decline Response API failed: \(error)")
                        self.showAlert(
                            title: "Error",
                            message: "Network error. Please try again."
                        )
                    }
                }
            }
        }
    }

    // MARK: - Navigate to DeclinedsuccessVC
    private func navigateToDeclinedSuccess(
        responseData: PTMParentResponseData?,
        remarks: String
    ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let vc = storyboard.instantiateViewController(
            withIdentifier: "DeclinedsuccessVC"
        ) as? DeclinedsuccessVC {
            configureAndPresentDeclinedSuccess(
                vc,
                responseData: responseData,
                remarks: remarks
            )
            return
        }

        let possibleIDs = ["DeclinedSuccess", "DeclineSuccessVC", "DeclineSuccess"]
        for id in possibleIDs {
            if let vc = storyboard.instantiateViewController(
                withIdentifier: id
            ) as? DeclinedsuccessVC {
                configureAndPresentDeclinedSuccess(
                    vc,
                    responseData: responseData,
                    remarks: remarks
                )
                return
            }
        }

        let vc = DeclinedsuccessVC()
        configureAndPresentDeclinedSuccess(
            vc,
            responseData: responseData,
            remarks: remarks
        )
    }

    private func configureAndPresentDeclinedSuccess(
        _ vc: DeclinedsuccessVC,
        responseData: PTMParentResponseData?,
        remarks: String
    ) {
        vc.meeting         = meeting
        vc.meetingID       = meetingID
        vc.studentID       = studentID
        vc.schoolID        = schoolID
        vc.responseData    = responseData
        vc.selectedRemarks = remarks
        vc.hidesBottomBarWhenPushed = true

        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: false)
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: - Alert Helper
    private func showAlert(
        title: String,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension MeetingdeclinepopupVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if selectedRemark == "Other" {
            print("📝 Other reason typed: \(textField.text ?? "")")
        }
    }
}
