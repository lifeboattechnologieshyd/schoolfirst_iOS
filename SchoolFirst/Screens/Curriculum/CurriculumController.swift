//
//  CurriculumController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    var selected_student = 0
    var types = [Curriculum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        
        self.getCurriculumType()
        
        self.tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil), forCellReuseIdentifier: "CurriculumTypeCell")
        if UserManager.shared.kids.count == 0 {
            selected_student = 0
            colVw.isHidden = true
            tblVw.isHidden = true
            
        }else {
            colVw.delegate = self
            colVw.dataSource = self
            tblVw.delegate = self
            tblVw.dataSource = self
            
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        cell.setup(student: UserManager.shared.kids[indexPath.row], isSelected: selected_student ==  indexPath.row)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected_student = indexPath.row
        colVw.reloadItems(at: [indexPath])
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        colVw.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width-20)/2
        return CGSize(width: width, height: 80)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTypeCell") as? CurriculumTypeCell
        cell?.lblDesc.text = types[indexPath.row].description
        cell?.lblName.text = types[indexPath.row].curriculumName
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
