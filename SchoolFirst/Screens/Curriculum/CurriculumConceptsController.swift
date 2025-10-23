//
//  CurriculumConceptsController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/10/25.
//

import UIKit

class CurriculumConceptsController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topView: UIView!
    var selected_lesson : Lesson!
    var concepts = [LessonConcept]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVw.register(UINib(nibName: "CurriculumConceptCell", bundle: nil), forCellReuseIdentifier: "CurriculumConceptCell")
        topView.addBottomShadow()
        tblVw.delegate = self
        tblVw.dataSource = self
        getConcepts()
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func getConcepts() {
        let subject_url = API.CONCEPTS + "\(selected_lesson.id)"
        NetworkManager.shared.request(urlString: subject_url,method: .GET) { (result: Result<APIResponse<[LessonConcept]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.concepts = data.sorted { $0.priority < $1.priority }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.concepts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "CurriculumConceptCell") as! CurriculumConceptCell
        cell.lblTitle.text = "\(self.concepts[indexPath.row].title)"
        cell.lblDescription.text = "\(self.concepts[indexPath.row].description)"
        cell.imgVw.loadImage(url: "\(self.concepts[indexPath.row].images[0])")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stbd = UIStoryboard(name: "curriculum", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "ConceptDetailController") as? ConceptDetailController
        vc?.concept = self.concepts[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
}
