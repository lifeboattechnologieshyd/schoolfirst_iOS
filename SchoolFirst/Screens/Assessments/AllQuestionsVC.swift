//
//  AllQuestionsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 11/11/25.
//

import UIKit

class AllQuestionsVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    var questions = [AssessmentQuestionHistoryDetails]()
    var assessmentId : String!
    var is_back_to_root = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        getHistoryQuestoins()
        tblVw.rowHeight = UITableView.automaticDimension
        tblVw.estimatedRowHeight = 300

        tblVw.delegate = self
        tblVw.dataSource = self
    }

    private func registerCells() {
        tblVw.register(UINib(nibName: "QuestionOneCell", bundle: nil), forCellReuseIdentifier: "QuestionOneCell")
        tblVw.register(UINib(nibName: "QuestionTwoCell", bundle: nil), forCellReuseIdentifier: "QuestionTwoCell")
      }
    
    func getHistoryQuestoins() {
        let url = API.ASSESSMENT_HISTORY_ANSWERS + "?student_id=\(UserManager.shared.assessmentSelectedStudent.studentID)&assessment=\(assessmentId!)"
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[AssessmentQuestionHistoryDetails]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.questions = data
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

extension AllQuestionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionOneCell") as! QuestionOneCell
        cell.setup(row: indexPath.row, question: self.questions[indexPath.row], ques: self.questions.count)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if is_back_to_root {
            navigationController?.popToRootViewController(animated: true)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
}



