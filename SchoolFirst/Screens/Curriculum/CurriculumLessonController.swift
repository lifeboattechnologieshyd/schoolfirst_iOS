//
//  CurriculumLessonController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 22/10/25.
//

import UIKit

class CurriculumLessonController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    var subj : GradeSubject!
    var lessons = [Lesson]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVw.register(UINib(nibName: "CurriculumLessonCell", bundle: nil), forCellReuseIdentifier: "CurriculumLessonCell")
        getLessons()
        topView.addBottomShadow()
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    
    func getLessons() {
        let subject_url = API.LESSON + "?grade=\(UserManager.shared.curriculamSelectedStudent.gradeID)&subject=\(subj.id)"
        NetworkManager.shared.request(urlString: subject_url,method: .GET) { (result: Result<APIResponse<[Lesson]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.lessons = data
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
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "CurriculumLessonCell") as! CurriculumLessonCell
        cell.lblName.text = "\(indexPath.row + 1). \(self.lessons[indexPath.row].lessonName)"
        cell.lblNumber.text = "\(self.lessons[indexPath.row].numberOfConcepts) Concepts"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stbd = UIStoryboard(name: "curriculum", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "CurriculumConceptsController") as? CurriculumConceptsController
        vc?.selected_lesson = self.lessons[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
