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

    // MARK: - Public Properties
    var meeting   : PTMMeeting?
    var meetingID : String = ""
    var studentID : String = ""
    var schoolID  : String = ""

    // ✅ NEW: Callback to inform parent about API result
    var onResponsePosted: ((_ status: String) -> Void)?

    // MARK: - Private State
    private var selectedRemark: String = ""
    private var isPostingDecline: Bool = false

    private let remarkOptions: [String] = [
        "Personal Emergency",
        "Out of Town",
        "Other"
    ]

    private var selectedLabel: UILabel?

    private var personalCheckmark : UIImageView?
    private var outOfTownCheckmark: UIImageView?
    private var otherCheckmark    : UIImageView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCheckmarks()
        setupGestures()
        setupTextField()

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📌 MeetingdeclinepopupVC — viewDidLoad")
        print("   meetingID : \(meetingID.isEmpty ? "⚠️ EMPTY" : meetingID)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Setup UI
    private func setupUI() {
        ConfirmdeclineButton.layer.cornerRadius = 8
        ConfirmdeclineButton.clipsToBounds      = true
        GobackButton.layer.cornerRadius = 8
        GobackButton.clipsToBounds      = true
        textfield.isHidden = true
    }

    // MARK: - Setup Checkmark Icons
    private func setupCheckmarks() {
        personalCheckmark  = addCheckmark(to: personalemergencyLbl)
        outOfTownCheckmark = addCheckmark(to: outoftownLbl)
        otherCheckmark     = addCheckmark(to: otherLbl)
        personalCheckmark?.isHidden  = true
        outOfTownCheckmark?.isHidden = true
        otherCheckmark?.isHidden     = true
    }

    private func addCheckmark(to label: UILabel) -> UIImageView {
        let checkmark = UIImageView()
        checkmark.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        checkmark.image = UIImage(
            systemName: "checkmark.circle.fill",
            withConfiguration: config
        )?.withTintColor(
            UIColor(red: 0/255, green: 51/255, blue: 191/255, alpha: 1),
            renderingMode: .alwaysOriginal
        )
        checkmark.contentMode = .scaleAspectFit

        guard let parent = label.superview else { return checkmark }
        parent.addSubview(checkmark)

        NSLayoutConstraint.activate([
            checkmark.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            checkmark.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 134),
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

    // MARK: - Setup Tap Gestures
    private func setupGestures() {
        let personalTap = UITapGestureRecognizer(target: self, action: #selector(personalEmergencyTapped))
        personalemergencyLbl.isUserInteractionEnabled = true
        personalemergencyLbl.addGestureRecognizer(personalTap)

        let outOfTownTap = UITapGestureRecognizer(target: self, action: #selector(outOfTownTapped))
        outoftownLbl.isUserInteractionEnabled = true
        outoftownLbl.addGestureRecognizer(outOfTownTap)

        let otherTap = UITapGestureRecognizer(target: self, action: #selector(otherTapped))
        otherLbl.isUserInteractionEnabled = true
        otherLbl.addGestureRecognizer(otherTap)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    // MARK: - Remark Selection Actions
    @objc private func personalEmergencyTapped() { selectRemark("Personal Emergency", label: personalemergencyLbl) }
    @objc private func outOfTownTapped()         { selectRemark("Out of Town", label: outoftownLbl) }
    @objc private func otherTapped()             { selectRemark("Other", label: otherLbl) }

    private func selectRemark(_ remark: String, label: UILabel) {
        selectedRemark = remark
        selectedLabel  = label
        updateCheckmarks(for: remark)
        if remark == "Other" {
            textfield.isHidden = false
            textfield.becomeFirstResponder()
        } else {
            textfield.isHidden = true
            textfield.text     = ""
            dismissKeyboard()
        }
    }

    private func updateCheckmarks(for remark: String) {
        personalCheckmark?.isHidden  = true
        outOfTownCheckmark?.isHidden = true
        otherCheckmark?.isHidden     = true
        switch remark {
        case "Personal Emergency": personalCheckmark?.isHidden  = false
        case "Out of Town":        outOfTownCheckmark?.isHidden = false
        case "Other":              otherCheckmark?.isHidden     = false
        default: break
        }
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
        guard !isPostingDecline else { return }

        var finalRemarks = selectedRemark

        if selectedRemark == "Other" {
            let typedText = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if typedText.isEmpty {
                showAlert(title: "Remarks Required", message: "Please enter your reason.")
                return
            }
            finalRemarks = typedText
        } else if selectedRemark.isEmpty {
            showAlert(title: "Select Reason", message: "Please select a reason for declining.")
            return
        }

        postDeclineResponse(remarks: finalRemarks)
    }

    // MARK: - POST Parent Response (NOT_ATTENDING)
    private func postDeclineResponse(remarks: String) {
        let schoolId  = schoolID.isEmpty  ? UserManager.shared.resolvedSchoolID  : schoolID
        let studentId = studentID.isEmpty ? UserManager.shared.resolvedStudentID : studentID

        guard !meetingID.isEmpty, !studentId.isEmpty else {
            showAlert(title: "Error", message: "Missing meeting information.")
            return
        }

        isPostingDecline = true

        let baseURL = API.BASE_URL.hasSuffix("/")
                        ? String(API.BASE_URL.dropLast())
                        : API.BASE_URL

        let urlString = "\(baseURL)/ptm/parent-response/\(meetingID)?student_id=\(studentId)"

        let bodyDict: [String: Any] = [
            "student_id":      studentId,
            "response_status": PTMResponseStatus.notAttending.rawValue,
            "remarks":         remarks
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else { return }
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(schoolId, forHTTPHeaderField: "X-School-Id")
        request.httpBody = jsonData
        request.timeoutInterval = 60

        // Add auth token
        let possibleKeys = ["ACCESSTOKEN", "accessToken", "access_token", "token"]
        for key in possibleKeys {
            if let storedToken = UserDefaults.standard.string(forKey: key) {
                let cleaned = storedToken.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleaned.isEmpty {
                    let authValue = cleaned.lowercased().hasPrefix("bearer ") || cleaned.lowercased().hasPrefix("token ")
                        ? cleaned
                        : "Bearer \(cleaned)"
                    request.setValue(authValue, forHTTPHeaderField: "Authorization")
                    break
                }
            }
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isPostingDecline = false

                if let error = error {
                    self.showAlert(title: "Error", message: "Network error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    self.showAlert(title: "Error", message: "Invalid server response.")
                    return
                }

                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("📥 Decline Response status: \(httpResponse.statusCode)")
                print("📥 Decline Response body: \(responseString)")

                do {
                    let decoded = try JSONDecoder().decode(
                        APIResponse<PTMParentResponseData>.self,
                        from: data
                    )

                    if decoded.success {
                        print("✅ Decline Response API success")
                        
                        // ✅ Trigger callback with the response status
                        self.onResponsePosted?(decoded.data?.responseStatus ?? "NOT_ATTENDING")
                        
                        self.navigateToDeclinedSuccess(
                            responseData: decoded.data,
                            remarks: remarks
                        )
                    } else {
                        self.showAlert(
                            title: "Error",
                            message: decoded.description.isEmpty
                                ? "Failed to decline. Please try again."
                                : decoded.description
                        )
                    }
                } catch {
                    if (200...299).contains(httpResponse.statusCode) {
                        // ✅ Even if decode fails, treat as success
                        self.onResponsePosted?("NOT_ATTENDING")
                        self.navigateToDeclinedSuccess(
                            responseData: nil,
                            remarks: remarks
                        )
                    } else {
                        self.showAlert(title: "Error", message: responseString)
                    }
                }
            }
        }.resume()
    }

    // MARK: - Navigate to DeclinedsuccessVC
    private func navigateToDeclinedSuccess(
        responseData: PTMParentResponseData?,
        remarks: String
    ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        var vc: DeclinedsuccessVC?
        if let typed = storyboard.instantiateViewController(
            withIdentifier: "DeclinedsuccessVC"
        ) as? DeclinedsuccessVC {
            vc = typed
        } else {
            let possibleIDs = ["DeclinedSuccess", "DeclineSuccessVC", "DeclineSuccess"]
            for id in possibleIDs {
                if let typed = storyboard.instantiateViewController(withIdentifier: id) as? DeclinedsuccessVC {
                    vc = typed
                    break
                }
            }
        }

        if vc == nil {
            vc = DeclinedsuccessVC()
        }

        if let vc = vc {
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
    }

    // MARK: - Alert Helper
    private func showAlert(
        title: String,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        if presentedViewController != nil { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
}
