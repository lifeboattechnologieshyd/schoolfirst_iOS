//
//  DateViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import UIKit

class DateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var dates = [VocabeeDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topbarView.addBottomShadow()
        
        getDates()
        
        tblVw.register(UINib(nibName: "VocabBeeDateCell", bundle: nil), forCellReuseIdentifier: "VocabBeeDateCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
    }
    
    func getDates() {
        guard let student = UserManager.shared.vocabBee_selected_student else {
            showAlert(msg: "Please select a student first.")
            return
        }
        
        guard let grade = UserManager.shared.vocabBee_selected_grade else {
            showAlert(msg: "Please select a grade first.")
            return
        }
        
        // ✅ Correct: studentID (not gradeID)
        let studentID = student.studentID.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ✅ Grade parameter – prefer grade.id, fallback to gradeID or grade name
        var gradeParam = grade.id.trimmingCharacters(in: .whitespacesAndNewlines)
        if gradeParam.isEmpty {
            gradeParam = student.gradeID.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if gradeParam.isEmpty {
            gradeParam = student.grade.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // ✅ Ensure both are present
        guard !studentID.isEmpty, !gradeParam.isEmpty else {
            showAlert(msg: "Student information is incomplete.")
            return
        }
        
        showLoader()
        
        let url = API.VOCABEE_GET_DATES + "?student_id=\(studentID)&grade=\(gradeParam)"
        print("🔗 Request URL: \(url)")
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[VocabeeDate]>, NetworkError>) in
            self.hideLoader()
            
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.dates = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                } else {
                    print(info.description)
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VocabBeeDateCell") as! VocabBeeDateCell
        cell.setup(item: self.dates[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserManager.shared.vocabBee_selected_date = self.dates[indexPath.row]
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "DailyChallengeViewController") as? DailyChallengeViewController {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let gradeVC = storyboard.instantiateViewController(withIdentifier: "DailyChallengeViewController") as? DailyChallengeViewController {
            self.navigationController?.pushViewController(gradeVC, animated: true)
        }
    }
}
