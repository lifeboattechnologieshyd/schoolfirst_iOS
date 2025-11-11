//
//  SelectCurriculumVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class SelectCurriculumVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var paranparaButton: UIButton!
    @IBOutlet weak var oxfordButton: UIButton!
    var types = [Curriculum]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClickParanpara(_ sender: UIButton) {
         let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as! AssessmentsGradeSelectionVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func getCurriculumType(){
        NetworkManager.shared.request(urlString: API.CURRICULUM_TYPES, method: .GET) { (result: Result<APIResponse<[Curriculum]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.types = data
                    }
                    DispatchQueue.main.async {
//                        self.tblVw.reloadData()
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


