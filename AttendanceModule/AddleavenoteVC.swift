//
//  AddleavenoteVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class AddleavenoteVC: UIViewController {
    
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!
    
    // MARK: - Data received from previous screen
    var attendanceId: String?
    var studentId: String?
    var attendanceDate: String?
    var attendanceStatus: String?
    var studentName: String?
    var admissionNumber: String?
    
    // MARK: - Submission State
    // Remembers that the note was submitted, so when the user pops back
    // from the success screen the cell shows the submitted note read-only.
    private var isSubmitted = false
    private var submittedData: AttendanceLateNoteData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-render when returning from the success screen so the
        // submitted note shows in success (read-only) mode.
        Tableview.reloadData()
    }
    
    // MARK: - Setup Back Button
    private func setupBackButton() {
        guard let button = backbutton else { return }
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    // MARK: - Back Button Action
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup TableView
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        
        let nib = UINib(nibName: "AddleavenoteTBLVCLL", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "AddleavenoteTBLVCLL")
        
        Tableview.tableFooterView = UIView()
    }
    
    // MARK: - API Call — Attendance Late Note (PUT)
    private func submitAttendanceNote(note: String) {
        
        // 1. Get School ID from DBManager / UserManager
        let schoolId = UserManager.shared.resolvedSchoolID
        if schoolId.isEmpty {
            AlertManager.shared.showAlert(
                title: "Error",
                message: "School ID not found. Please login again."
            )
            return
        }
        
        // 2. Get Access Token
        let accessToken = UserDefaults.standard.string(forKey: "ACCESSTOKEN")
        if accessToken == nil || accessToken!.isEmpty {
            AlertManager.shared.showAlert(
                title: "Authentication Error",
                message: "Session expired or invalid. Please login again."
            )
            return
        }
        
        // 3. Get Student ID from UserManager fallback
        let studentID = (studentId ?? "").isEmpty
            ? UserManager.shared.resolvedStudentID
            : studentId!
        
        // 4. Build payload — send both late_note and absent_note based on status
        let statusUppercased = (attendanceStatus ?? "").uppercased()
        var lateNote = ""
        var absentNote = ""
        
        if statusUppercased == "LATE" {
            lateNote = note
        } else {
            absentNote = note
        }
        
        let parameters: [String: Any] = [
            "attendance_id": attendanceId ?? "",
            "student_id": studentID,
            "late_note": lateNote,
            "absent_note": absentNote
        ]
        
        // 5. Headers — X-School-ID (Authorization is auto-handled by NetworkManager)
        let headers: [String: String] = [
            "X-School-ID": schoolId
        ]
        
        // 6. API Call — PUT to attendance/late-note
        NetworkManager.shared.request(
            urlString: API.ATTENDANCE_LATE_NOTE,
            method: .PUT,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { (result: Result<APIResponse<AttendanceLateNoteData>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        // Remember submission so popping back shows
                        // the note read-only in success mode.
                        self.isSubmitted = true
                        self.submittedData = response.data
                        self.Tableview.reloadData()
                        
                        // Navigate to success screen with response data
                        let successVC = NotesubmitsuccessVC()
                        successVC.responseData = response.data
                        self.navigationController?.pushViewController(successVC, animated: true)
                    } else {
                        AlertManager.shared.showAlert(
                            title: "Error",
                            message: response.description.isEmpty
                                ? "Submission failed"
                                : response.description
                        )
                    }
                    
                case .failure(let error):
                    AlertManager.shared.showAlert(
                        title: "Error",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AddleavenoteVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AddleavenoteTBLVCLL",
            for: indexPath
        ) as? AddleavenoteTBLVCLL else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.delegate = self
        
        if isSubmitted {
            // ✅ Show the submitted note top-aligned and read-only
            cell.configureSuccess(data: submittedData)
        } else {
            cell.configure(
                attendanceStatus: attendanceStatus,
                attendanceDate: attendanceDate
            )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}

// MARK: - AddleavenoteTBLVCLLDelegate
extension AddleavenoteVC: AddleavenoteTBLVCLLDelegate {
    
    func didTapSubmitLeaveNote(note: String) {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedNote.isEmpty {
            AlertManager.shared.showAlert(
                title: "Alert",
                message: "Please enter leave note"
            )
            return
        }
        
        submitAttendanceNote(note: trimmedNote)
    }
    
    func didTapBackToAttendance() {
        navigationController?.popViewController(animated: true)
    }
}
