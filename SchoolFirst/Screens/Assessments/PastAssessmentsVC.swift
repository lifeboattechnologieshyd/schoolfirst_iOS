//
//  PastAssessmentsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 10/11/25.
//

import UIKit

class PastAssessmentsVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    var assessments = [AssessmentSummary]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getHistory()
        tblVw.register(UINib(nibName: "AssessmentCardCell", bundle: nil), forCellReuseIdentifier: "AssessmentCardCell")
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
   
    private func navigateToAllQuestions(ass_id : String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AllQuestionsVC") as! AllQuestionsVC
        vc.assessmentId = ass_id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func getHistory() {
        let url = API.ASSESSMENT_HISTORY + "?student_id=\(UserManager.shared.assessmentSelectedStudent.studentID)"
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[AssessmentSummary]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.assessments = data
                            self.tblVw.reloadData()
                        }
                    }
                }else{
                    print(info.description)
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
    
    
}

extension PastAssessmentsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assessments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentCardCell") as! AssessmentCardCell
        cell.backgroundColor = .clear
        cell.btnSeeAns.tag = indexPath.row
        cell.onSelectAns = { index in
            self.navigateToAllQuestions(ass_id: self.assessments[index].assessmentId)
        }
        cell.setup(assessment: self.assessments[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 181
    }
}
