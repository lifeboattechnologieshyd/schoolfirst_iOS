//
//  DateViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import  UIKit

class DateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var topbarView: UIView!
    
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topbarView.addBottomShadow()
        
        getDates()
        
        tblVw.register(UINib(nibName: "VocabBeeDateCell", bundle: nil), forCellReuseIdentifier: "VocabBeeDateCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
    }
    
    func getDates() {
        var url = API.VOCABEE_GET_DATES + "?student_id=\(UserManager.shared.vocabBee_selected_student.gradeID)&grade=\(UserManager.shared.vocabBee_selected_grade.id)"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[GradeModel]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VocabBeeDateCell") as! VocabBeeDateCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
