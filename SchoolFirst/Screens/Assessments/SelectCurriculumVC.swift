//
//  SelectCurriculumVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class SelectCurriculumVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var tblVw: UITableView!
    
    var types = [Curriculum]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil), forCellReuseIdentifier: "CurriculumTypeCell")
        self.getCurriculumType()
        self.tblVw.delegate = self
        self.tblVw.dataSource = self

    }
    
 
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTypeCell") as? CurriculumTypeCell
        cell?.backgroundColor = .clear
        cell?.lblDesc.text = types[indexPath.row].description
        cell?.lblName.text = types[indexPath.row].curriculumName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as! AssessmentsGradeSelectionVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCurriculumType(){
        showLoader()
        NetworkManager.shared.request(urlString: API.CURRICULUM_TYPES, method: .GET) { (result: Result<APIResponse<[Curriculum]>, NetworkError>)  in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.types = data
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


