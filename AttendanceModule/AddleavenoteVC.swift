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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()
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
    
    // MARK: - API Call - Apply Student Leave
    private func applyStudentLeave(note: String) {
        
        // 1. Get School ID
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
        
        // 3. Build parameters — only include the relevant note key
        var parameters: [String: Any] = [
            "attendance_id": attendanceId ?? "",
            "student_id": studentId ?? ""
        ]
        
        let statusUppercased = attendanceStatus?.uppercased() ?? ""
        
        if statusUppercased == "LATE" {
            parameters["late_note"] = note
            // ✅ Removed NSNull() — just omit the key entirely
        } else {
            parameters["absent_note"] = note
            // ✅ Removed NSNull() — just omit the key entirely
        }
        
        // 4. Prepare Headers
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken!)",
            "X-School-Id": schoolId
        ]
        
        // 5. API Call — PUT as confirmed by backend developer
        NetworkManager.shared.request(
            urlString: API.APPLY_STUDENT_LEAVE,
            method: .PUT,
            parameters: parameters,
            headers: headers
        ) { (result: Result<APIResponse<ApplyStudentLeaveResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self.navigationController?.popViewController(animated: true)
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
        cell.configure(
            attendanceStatus: attendanceStatus,
            attendanceDate: attendanceDate
        )
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
        
        applyStudentLeave(note: trimmedNote)
    }
}
