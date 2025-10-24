//
//  CurriculumCategoryController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumCategoryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topView: UIView!
    var cats = [CurriculumCategory]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVw.register(UINib(nibName: "CurriculamCategoryCell", bundle: nil), forCellReuseIdentifier: "CurriculamCategoryCell")
        topView.addBottomShadow()
        getCurriculumCats()
        tblVw.delegate = self
        tblVw.dataSource = self
        
        
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cats.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculamCategoryCell") as! CurriculamCategoryCell
        cell.imgVw.loadImage(url: cats[indexPath.row].categoryImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stbd = UIStoryboard(name: "curriculum", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "CurriculumSubjectController") as! CurriculumSubjectController
        vc.selected_category = cats[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCurriculumCats(){
        let url = API.CURRICULUM_CATEGORIES + "\(UserManager.shared.curriculamSelectedStudent.gradeID)"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[CurriculumCategory]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.cats = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                }else{
                    self.showAlert(msg: info.description)
                }
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    
}
