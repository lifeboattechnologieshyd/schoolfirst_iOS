//
//  AssessmentLessonVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class AssessmentLessonVC: UIViewController {
    var subject_id = ""
    var grade_id = ""
    var lessons = [Lesson]()
    
    @IBOutlet weak var tblVw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getLessons()
        tblVw.register(UINib(nibName: "LessonCell", bundle: nil), forCellReuseIdentifier: "LessonCell")
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickStartTest(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "AssessmentPreparationVC") as? AssessmentPreparationVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    
    func getLessons() {
        var subject_url = API.LESSON + "?grade=\(grade_id)&subject=\(subject_id)"
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
    
}

extension AssessmentLessonVC: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell") as! LessonCell
        cell.lblName.text = "\(indexPath.row + 1). " + self.lessons[indexPath.row].lessonName
        cell.btnSelect.tag = indexPath.row
        cell.onSelectingLesson = { index in
            print("selected row")
            self.lessons[index].selected.toggle()
            UserManager.shared.assessment_selected_lesson_ids.append(self.lessons[index].id)
            cell.btnSelect.setImage(UIImage(named: "lesson_selection"), for: .normal)
            self.tblVw.reloadData()
        }
        if self.lessons[indexPath.row].selected {
            cell.btnSelect.setImage(UIImage(named: "lesson_selection"), for: .normal)
        } else {
            cell.btnSelect.setImage(UIImage(named: "add"), for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserManager.shared.assessment_selected_lesson_ids.append(self.lessons[indexPath.row].id)
    }
}
